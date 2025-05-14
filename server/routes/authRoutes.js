const express = require('express');
const router = express.Router();
const { register, login } = require('../controllers/authController');
const connectDB = require('../config/db');

let isConnected = false;

// Middleware to ensure database connection
async function ensureConnection(req, res, next) {
    try {
        if (!isConnected) {
            await connectDB();
            isConnected = true;
        }
        next();
    } catch (err) {
        console.error('Database connection error in middleware:', err);
        res.status(500).json({ error: 'Database connection failed', details: err.message });
    }
}

// Debug middleware for auth routes
router.use((req, res, next) => {
    console.log('Auth route accessed:', {
        method: req.method,
        url: req.url,
        path: req.path,
        baseUrl: req.baseUrl,
        originalUrl: req.originalUrl,
        body: req.body
    });
    next();
});

// Register route
router.post('/register', ensureConnection, register);

// Login route
router.post('/login', ensureConnection, login);

// Test route to verify router is working
router.get('/test', (req, res) => {
    console.log('Auth test endpoint hit');
    res.json({ 
        message: 'Auth router is working',
        path: req.path,
        baseUrl: req.baseUrl,
        originalUrl: req.originalUrl
    });
});

module.exports = router; 