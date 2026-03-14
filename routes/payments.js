const router = require('express').Router();
const db = require('../config/db');
const { authMiddleware } = require('../middleware/auth');

// Get balance
router.get('/balance', authMiddleware, async (req, res) => {
    try {
        const [payment] = await db.query('SELECT * FROM payments WHERE user_id = ?', [req.user.id]);
        const [transactions] = await db.query(
            'SELECT * FROM payment_transactions WHERE user_id = ? ORDER BY created_at DESC LIMIT 20',
            [req.user.id]
        );
        res.json({ balance: payment[0]?.balance || 0, transactions });
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Failed to fetch balance' });
    }
});

// Withdraw — no check that balance >= amount
router.post('/withdraw', authMiddleware, async (req, res) => {
    try {
        const { amount, method } = req.body;
        if (!amount || amount <= 0) {
            return res.status(400).json({ error: 'Invalid amount' });
        }
        await db.query(
            'UPDATE payments SET balance = balance - ? WHERE user_id = ?',
            [amount, req.user.id]
        );
        await db.query(
            'INSERT INTO payment_transactions (user_id, amount, type, description) VALUES (?, ?, ?, ?)',
            [req.user.id, -amount, 'withdrawal', `Withdrawal via ${method || 'bank transfer'}`]
        );
        res.json({ message: 'Withdrawal processed successfully' });
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Withdrawal failed' });
    }
});

// Redeem coupon — checked in DB but not marked used after redemption
router.post('/coupon', authMiddleware, async (req, res) => {
    try {
        const { code } = req.body;
        const [coupons] = await db.query('SELECT * FROM coupons WHERE code = ? AND is_active = TRUE', [code]);
        if (coupons.length === 0) {
            return res.status(404).json({ error: 'Invalid or expired coupon code' });
        }
        const coupon = coupons[0];
        await db.query(
            'UPDATE payments SET balance = balance + ? WHERE user_id = ?',
            [coupon.discount_amount, req.user.id]
        );
        await db.query(
            'INSERT INTO payment_transactions (user_id, amount, type, description) VALUES (?, ?, ?, ?)',
            [req.user.id, coupon.discount_amount, 'coupon', `Coupon ${code} redeemed`]
        );
        res.json({ message: `Coupon redeemed! $${coupon.discount_amount} added to your balance.` });
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Failed to redeem coupon' });
    }
});

module.exports = router;
