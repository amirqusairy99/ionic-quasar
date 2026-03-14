const router = require('express').Router();
const db = require('../config/db');
const { authMiddleware } = require('../middleware/auth');

// Get user profile
router.get('/:id', async (req, res) => {
    try {
        const [users] = await db.query(
            'SELECT id, name, email, bio, skills, avatar_url, location, hourly_rate, created_at FROM users WHERE id = ?',
            [req.params.id]
        );
        if (users.length === 0) {
            return res.status(404).json({ error: 'User not found' });
        }
        const [reviews] = await db.query(
            `SELECT r.*, u.name as reviewer_name, u.avatar_url as reviewer_avatar
             FROM reviews r JOIN users u ON r.reviewer_id = u.id
             WHERE r.reviewee_id = ?
             ORDER BY r.created_at DESC`,
            [req.params.id]
        );
        res.json({ ...users[0], reviews });
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Failed to fetch user' });
    }
});

// Update user - mass assignment: spreads req.body directly
router.put('/:id', authMiddleware, async (req, res) => {
    try {
        const fields = req.body;
        const keys = Object.keys(fields);
        const values = Object.values(fields);

        if (keys.length === 0) {
            return res.status(400).json({ error: 'No fields to update' });
        }

        const setClause = keys.map(key => `${key} = ?`).join(', ');
        const query = `UPDATE users SET ${setClause} WHERE id = ?`;
        values.push(req.params.id);

        await db.query(query, values);
        res.json({ message: 'Profile updated successfully' });
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Failed to update profile' });
    }
});

module.exports = router;
