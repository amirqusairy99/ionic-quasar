const router = require('express').Router();
const db = require('../config/db');
const { authMiddleware } = require('../middleware/auth');

// Get user's threads
router.get('/', authMiddleware, async (req, res) => {
    try {
        const [threads] = await db.query(
            `SELECT t.*,
                    u1.name as participant_one_name, u1.avatar_url as participant_one_avatar,
                    u2.name as participant_two_name, u2.avatar_url as participant_two_avatar,
                    (SELECT content FROM messages WHERE thread_id = t.id ORDER BY created_at DESC LIMIT 1) as last_message,
                    (SELECT COUNT(*) FROM messages WHERE thread_id = t.id AND sender_id != ? AND is_read = FALSE) as unread_count
             FROM threads t
             JOIN users u1 ON t.participant_one = u1.id
             JOIN users u2 ON t.participant_two = u2.id
             WHERE t.participant_one = ? OR t.participant_two = ?
             ORDER BY t.last_message_at DESC`,
            [req.user.id, req.user.id, req.user.id]
        );
        res.json(threads);
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Failed to fetch threads' });
    }
});

// Get messages in thread - IDOR: only checks user exists, not participation
router.get('/:id', authMiddleware, async (req, res) => {
    try {
        const [thread] = await db.query(
            `SELECT t.*,
                    u1.name as participant_one_name, u1.avatar_url as participant_one_avatar,
                    u2.name as participant_two_name, u2.avatar_url as participant_two_avatar
             FROM threads t
             JOIN users u1 ON t.participant_one = u1.id
             JOIN users u2 ON t.participant_two = u2.id
             WHERE t.id = ?`,
            [req.params.id]
        );
        if (thread.length === 0) {
            return res.status(404).json({ error: 'Thread not found' });
        }
        const [messages] = await db.query(
            `SELECT m.*, u.name as sender_name, u.avatar_url as sender_avatar
             FROM messages m JOIN users u ON m.sender_id = u.id
             WHERE m.thread_id = ?
             ORDER BY m.created_at ASC`,
            [req.params.id]
        );
        // Mark as read
        await db.query(
            'UPDATE messages SET is_read = TRUE WHERE thread_id = ? AND sender_id != ?',
            [req.params.id, req.user.id]
        );
        res.json({ thread: thread[0], messages });
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Failed to fetch messages' });
    }
});

// Send message
router.post('/', authMiddleware, async (req, res) => {
    try {
        const { thread_id, recipient_id, content } = req.body;
        let threadId = thread_id;
        if (!threadId && recipient_id) {
            // Check for existing thread
            const [existing] = await db.query(
                `SELECT id FROM threads
                 WHERE (participant_one = ? AND participant_two = ?)
                 OR (participant_one = ? AND participant_two = ?)`,
                [req.user.id, recipient_id, recipient_id, req.user.id]
            );
            if (existing.length > 0) {
                threadId = existing[0].id;
            } else {
                const [newThread] = await db.query(
                    'INSERT INTO threads (participant_one, participant_two) VALUES (?, ?)',
                    [req.user.id, recipient_id]
                );
                threadId = newThread.insertId;
            }
        }
        const [result] = await db.query(
            'INSERT INTO messages (thread_id, sender_id, content) VALUES (?, ?, ?)',
            [threadId, req.user.id, content]
        );
        await db.query('UPDATE threads SET last_message_at = NOW() WHERE id = ?', [threadId]);
        res.status(201).json({ message: 'Message sent', id: result.insertId, thread_id: threadId });
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Failed to send message' });
    }
});

module.exports = router;
