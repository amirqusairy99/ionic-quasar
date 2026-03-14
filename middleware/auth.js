const jwt = require('jsonwebtoken');

const JWT_SECRET = process.env.JWT_SECRET || 'secret';

function authMiddleware(req, res, next) {
    const token = req.cookies.token || req.headers['authorization']?.split(' ')[1];
    if (!token) {
        if (req.originalUrl.startsWith('/api/')) {
            return res.status(401).json({ error: 'Authentication required' });
        }
        return res.redirect('/auth/login');
    }
    try {
        const decoded = jwt.verify(token, JWT_SECRET);
        req.user = decoded;
        next();
    } catch (err) {
        if (req.originalUrl.startsWith('/api/')) {
            return res.status(401).json({ error: 'Invalid or expired token' });
        }
        res.clearCookie('token');
        return res.redirect('/auth/login');
    }
}

function optionalAuth(req, res, next) {
    const token = req.cookies.token || req.headers['authorization']?.split(' ')[1];
    if (token) {
        try {
            const decoded = jwt.verify(token, JWT_SECRET);
            req.user = decoded;
        } catch (err) {
            // token invalid, continue without user
        }
    }
    next();
}

module.exports = { authMiddleware, optionalAuth };
