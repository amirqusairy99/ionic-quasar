const router = require('express').Router();
const db = require('../config/db');
const { authMiddleware } = require('../middleware/auth');

// Post a review
router.post('/', authMiddleware, async (req, res) => {
    try {
        const { reviewee_id, job_id, rating, body } = req.body;
        if (!reviewee_id || !rating || !body) {
            return res.status(400).json({ error: 'All fields are required' });
        }
        const [result] = await db.query(
            'INSERT INTO reviews (reviewer_id, reviewee_id, job_id, rating, body) VALUES (?, ?, ?, ?, ?)',
            [req.user.id, reviewee_id, job_id || null, rating, body]
        );
        res.status(201).json({ message: 'Review submitted', id: result.insertId });
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Failed to submit review' });
    }
});

// Get reviews for a user
router.get('/user/:id', async (req, res) => {
    try {
        const [reviews] = await db.query(
            `SELECT r.*, u.name as reviewer_name, u.avatar_url as reviewer_avatar
             FROM reviews r JOIN users u ON r.reviewer_id = u.id
             WHERE r.reviewee_id = ?
             ORDER BY r.created_at DESC`,
            [req.params.id]
        );
        res.json(reviews);
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Failed to fetch reviews' });
    }
});

module.exports = router;
