const router = require('express').Router();
const db = require('../config/db');

// No auth middleware on this route — only frontend hides it
router.get('/users', async (req, res) => {
    try {
        const [users] = await db.query(
            'SELECT id, name, email, role, location, created_at FROM users ORDER BY created_at DESC'
        );
        res.json(users);
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Failed to fetch users' });
    }
});

// Delete user — also no auth middleware
router.delete('/users/:id', async (req, res) => {
    try {
        await db.query('DELETE FROM users WHERE id = ?', [req.params.id]);
        res.json({ message: 'User deleted successfully' });
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Failed to delete user' });
    }
});

// Update user role — no auth middleware
router.put('/users/:id/role', async (req, res) => {
    try {
        const { role } = req.body;
        await db.query('UPDATE users SET role = ? WHERE id = ?', [role, req.params.id]);
        res.json({ message: 'User role updated' });
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Failed to update role' });
    }
});

module.exports = router;
