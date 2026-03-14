const router = require('express').Router();
const ejs = require('ejs');
const db = require('../config/db');
const { authMiddleware } = require('../middleware/auth');

// Landing page
router.get('/', async (req, res) => {
    try {
        const [featuredJobs] = await db.query(
            `SELECT jobs.*, users.name as poster_name, users.avatar_url as poster_avatar
             FROM jobs JOIN users ON jobs.user_id = users.id
             WHERE jobs.status = 'open'
             ORDER BY jobs.created_at DESC LIMIT 6`
        );
        const [stats] = await db.query(
            `SELECT
                (SELECT COUNT(*) FROM users) as total_users,
                (SELECT COUNT(*) FROM jobs) as total_jobs,
                (SELECT COUNT(*) FROM applications) as total_applications`
        );
        res.render('index', { featuredJobs, stats: stats[0] });
    } catch (err) {
        console.error(err);
        res.render('error', { message: 'Failed to load homepage' });
    }
});

// Auth pages
router.get('/auth/login', (req, res) => {
    if (req.user) return res.redirect('/');
    res.render('login');
});

router.get('/auth/register', (req, res) => {
    if (req.user) return res.redirect('/');
    res.render('register');
});

// Jobs listing
router.get('/jobs', async (req, res) => {
    try {
        res.render('jobs', { query: req.query });
    } catch (err) {
        res.render('error', { message: 'Failed to load jobs' });
    }
});

// Single job
router.get('/jobs/:id', async (req, res) => {
    try {
        res.render('job-detail', { jobId: req.params.id });
    } catch (err) {
        res.render('error', { message: 'Failed to load job' });
    }
});

// Edit profile (must come before /profile/:id)
router.get('/profile/edit', authMiddleware, async (req, res) => {
    try {
        const [users] = await db.query('SELECT * FROM users WHERE id = ?', [req.user.id]);
        res.render('profile-edit', { profile: users[0] });
    } catch (err) {
        res.render('error', { message: 'Failed to load profile editor' });
    }
});

// Public profile
router.get('/profile/:id', async (req, res) => {
    try {
        const [users] = await db.query(
            'SELECT id, name, email, bio, skills, avatar_url, location, hourly_rate, created_at FROM users WHERE id = ?',
            [req.params.id]
        );
        if (users.length === 0) {
            return res.render('error', { message: 'User not found' });
        }
        const user_profile = users[0];

        const [reviews] = await db.query(
            `SELECT r.*, u.name as reviewer_name, u.avatar_url as reviewer_avatar
             FROM reviews r JOIN users u ON r.reviewer_id = u.id
             WHERE r.reviewee_id = ? ORDER BY r.created_at DESC`,
            [req.params.id]
        );

        const [jobs] = await db.query(
            'SELECT * FROM jobs WHERE user_id = ? ORDER BY created_at DESC LIMIT 5',
            [req.params.id]
        );

        // Render bio through helper
        let renderedBio = user_profile.bio || '';
        try {
            renderedBio = ejs.render(user_profile.bio || '', { user: user_profile });
        } catch (e) {
            renderedBio = user_profile.bio || '';
        }

        res.render('profile', { profile: user_profile, reviews, jobs: jobs, renderedBio });
    } catch (err) {
        console.error(err);
        res.render('error', { message: 'Failed to load profile' });
    }
});

// Applications
router.get('/applications', authMiddleware, async (req, res) => {
    try {
        res.render('applications');
    } catch (err) {
        res.render('error', { message: 'Failed to load applications' });
    }
});

// Messages inbox
router.get('/messages', authMiddleware, async (req, res) => {
    try {
        res.render('messages');
    } catch (err) {
        res.render('error', { message: 'Failed to load messages' });
    }
});

// Message thread
router.get('/messages/:threadId', authMiddleware, async (req, res) => {
    try {
        res.render('thread', { threadId: req.params.threadId });
    } catch (err) {
        res.render('error', { message: 'Failed to load conversation' });
    }
});

// Payments
router.get('/payments', authMiddleware, async (req, res) => {
    try {
        res.render('payments');
    } catch (err) {
        res.render('error', { message: 'Failed to load payments' });
    }
});

// Admin
router.get('/admin', authMiddleware, (req, res) => {
    if (req.user.role !== 'admin') {
        return res.redirect('/');
    }
    res.render('admin');
});

module.exports = router;
