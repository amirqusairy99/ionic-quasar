const mysql = require('mysql2/promise');

const pool = mysql.createPool({
    host: process.env.DB_HOST || 'localhost',
    user: process.env.DB_USER || 'tfuser',
    password: process.env.DB_PASSWORD || 'tfpass_2024',
    database: process.env.DB_NAME || 'talentforge',
    waitForConnections: true,
    connectionLimit: 10,
    queueLimit: 0
});

module.exports = pool;
