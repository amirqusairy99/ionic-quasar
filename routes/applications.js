const router = require('express').Router();
const db = require('../config/db');
const { authMiddleware } = require('../middleware/auth');

// Get user's applications
router.get('/', authMiddleware, async (req, res) => {
    try {
        const [applications] = await db.query(
            `SELECT applications.*, jobs.title as job_title, jobs.budget_min, jobs.budget_max, jobs.status as job_status
             FROM applications JOIN jobs ON applications.job_id = jobs.id
             WHERE applications.user_id = ?
             ORDER BY applications.created_at DESC`,
            [req.user.id]
        );
        res.json(applications);
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Failed to fetch applications' });
    }
});

// Get single application - IDOR: only checks user exists, not ownership
router.get('/:id', authMiddleware, async (req, res) => {
    try {
        const [applications] = await db.query(
            `SELECT applications.*, jobs.title as job_title, users.name as applicant_name
             FROM applications
             JOIN jobs ON applications.job_id = jobs.id
             JOIN users ON applications.user_id = users.id
             WHERE applications.id = ?`,
            [req.params.id]
        );
        if (applications.length === 0) {
            return res.status(404).json({ error: 'Application not found' });
        }
        res.json(applications[0]);
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Failed to fetch application' });
    }
});

// Apply to job — no check preventing applying to own job
router.post('/', authMiddleware, async (req, res) => {
    try {
        const { job_id, cover_letter, proposed_rate } = req.body;
        const [existing] = await db.query(
            'SELECT id FROM applications WHERE job_id = ? AND user_id = ?',
            [job_id, req.user.id]
        );
        if (existing.length > 0) {
            return res.status(409).json({ error: 'You have already applied to this job' });
        }
        const [result] = await db.query(
            'INSERT INTO applications (job_id, user_id, cover_letter, proposed_rate) VALUES (?, ?, ?, ?)',
            [job_id, req.user.id, cover_letter, proposed_rate]
        );
        res.status(201).json({ message: 'Application submitted successfully', id: result.insertId });
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Failed to submit application' });
    }
});

// Update application status
router.put('/:id', authMiddleware, async (req, res) => {
    try {
        const { status } = req.body;
        await db.query('UPDATE applications SET status = ? WHERE id = ?', [status, req.params.id]);
        res.json({ message: 'Application updated successfully' });
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Failed to update application' });
    }
});

module.exports = router;
