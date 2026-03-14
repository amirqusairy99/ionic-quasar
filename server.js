require('dotenv').config();
const express = require('express');
const cookieParser = require('cookie-parser');
const path = require('path');
const ejs = require('ejs');

const app = express();

// View engine
app.set('view engine', 'ejs');
app.set('views', path.join(__dirname, 'views'));

// Middleware
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(cookieParser());
app.use(express.static(path.join(__dirname, 'public')));

// Make user available in all templates
const { optionalAuth } = require('./middleware/auth');
app.use(optionalAuth);
app.use((req, res, next) => {
    res.locals.user = req.user || null;
    res.locals.ejs = ejs;
    next();
});

// API Routes
app.use('/api/v1/auth', require('./routes/auth'));
app.use('/api/v1/jobs', require('./routes/jobs'));
app.use('/api/v1/applications', require('./routes/applications'));
app.use('/api/v1/messages', require('./routes/messages'));
app.use('/api/v1/users', require('./routes/users'));
app.use('/api/v1/payments', require('./routes/payments'));
app.use('/api/v1/admin', require('./routes/admin'));
app.use('/api/v1/reviews', require('./routes/reviews'));

// Page Routes
app.use('/', require('./routes/pages'));

// Error handler
app.use((err, req, res, next) => {
    console.error(err.stack);
    if (req.originalUrl.startsWith('/api/')) {
        return res.status(500).json({ error: 'Internal server error' });
    }
    res.status(500).render('error', { message: 'Something went wrong', error: err });
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
    console.log(`TalentForge running on http://localhost:${PORT}`);
});
