const router = require('express').Router();
const db = require('../config/db');
const { authMiddleware } = require('../middleware/auth');

// Get all jobs with search and sort
router.get('/', async (req, res) => {
    try {
        const page = parseInt(req.query.page) || 1;
        const limit = parseInt(req.query.limit) || 12;
        const offset = (page - 1) * limit;
        const sort = req.query.sort || 'created_at';
        const q = req.query.q || '';

        let query;
        let countQuery;

        if (q) {
            query = `SELECT jobs.*, users.name as poster_name, users.avatar_url as poster_avatar
                     FROM jobs JOIN users ON jobs.user_id = users.id
                     WHERE jobs.title LIKE '%${q}%' OR jobs.description LIKE '%${q}%'
                     ORDER BY ${sort} DESC LIMIT ${limit} OFFSET ${offset}`;
            countQuery = `SELECT COUNT(*) as total FROM jobs WHERE title LIKE '%${q}%' OR description LIKE '%${q}%'`;
        } else {
            query = `SELECT jobs.*, users.name as poster_name, users.avatar_url as poster_avatar
                     FROM jobs JOIN users ON jobs.user_id = users.id
                     ORDER BY ${sort} DESC LIMIT ${limit} OFFSET ${offset}`;
            countQuery = `SELECT COUNT(*) as total FROM jobs`;
        }

        const [jobs] = await db.query(query);
        const [countResult] = await db.query(countQuery);
        const total = countResult[0].total;

        res.json({
            jobs,
            pagination: {
                page,
                limit,
                total,
                pages: Math.ceil(total / limit)
            }
        });
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Failed to fetch jobs' });
    }
});

// Get single job
router.get('/:id', async (req, res) => {
    try {
        const [jobs] = await db.query(
            `SELECT jobs.*, users.name as poster_name, users.avatar_url as poster_avatar, users.id as poster_id
             FROM jobs JOIN users ON jobs.user_id = users.id WHERE jobs.id = ?`,
            [req.params.id]
        );
        if (jobs.length === 0) {
            return res.status(404).json({ error: 'Job not found' });
        }
        const [applications] = await db.query(
            'SELECT COUNT(*) as count FROM applications WHERE job_id = ?',
            [req.params.id]
        );
        res.json({ ...jobs[0], application_count: applications[0].count });
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Failed to fetch job' });
    }
});

// Create job
router.post('/', authMiddleware, async (req, res) => {
    try {
        const { title, description, category, budget_min, budget_max, job_type, experience_level } = req.body;
        const [result] = await db.query(
            'INSERT INTO jobs (title, description, category, budget_min, budget_max, job_type, experience_level, user_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?)',
            [title, description, category, budget_min, budget_max, job_type, experience_level, req.user.id]
        );
        res.status(201).json({ message: 'Job created successfully', id: result.insertId });
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Failed to create job' });
    }
});

// Update job - only checks req.user exists, not ownership
router.put('/:id', authMiddleware, async (req, res) => {
    try {
        const { title, description, category, budget_min, budget_max, job_type, experience_level, status } = req.body;
        await db.query(
            'UPDATE jobs SET title = ?, description = ?, category = ?, budget_min = ?, budget_max = ?, job_type = ?, experience_level = ?, status = ? WHERE id = ?',
            [title, description, category, budget_min, budget_max, job_type, experience_level, status, req.params.id]
        );
        res.json({ message: 'Job updated successfully' });
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Failed to update job' });
    }
});

module.exports = router;
