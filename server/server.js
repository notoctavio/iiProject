const express = require('express');
const cors = require('cors');
const rateLimit = require('express-rate-limit');
const helmet = require('helmet');
require('dotenv').config();
const connectDB = require('./config/db');
const authRoutes = require('./routes/authRoutes');
const friendRoutes = require('./routes/friendRoutes');
const personalTransactionRoutes = require('./routes/personalTransactionRoutes');

const app = express();

// Connect to MongoDB
if (process.env.NODE_ENV !== 'test') {
    connectDB(process.env.MONGODB_URI);
}

// Security middleware
app.use(helmet());

// CORS configuration
app.use(cors({
    origin: ['http://localhost:5173', 'http://localhost:3000', 'http://localhost:3001'],
    credentials: true,
    methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
    allowedHeaders: ['Content-Type', 'Authorization']
}));

// Add request logging middleware
app.use((req, res, next) => {
    console.log('Incoming request:', {
        method: req.method,
        path: req.path,
        body: req.body,
        headers: req.headers
    });
    next();
});

// Rate limiting
const limiter = rateLimit({
    windowMs: 15 * 60 * 1000,
    max: 100
});
app.use('/auth/', limiter);

app.use(express.json({ limit: '10kb' }));

// Basic route for testing
app.get('/', (req, res) => {
    res.json({ message: "Server is running" });
});

// Test route without auth
app.get('/test', (req, res) => {
    res.json({ message: "Test route working" });
});

// Mount auth routes
app.use('/auth', authRoutes);
app.use('/friends', friendRoutes);
app.use('/personal-transactions', personalTransactionRoutes);

// Add this middleware before routes
app.use((req, res, next) => {
  console.log(`${req.method} ${req.path}`, req.body);
  next();
});

// Error handling
app.use((err, req, res, next) => {
    console.error(err.stack);
    res.status(500).json({ error: 'Something went wrong' });
});

// 404 handler - keep this last
app.use((req, res) => {
    res.status(404).json({ 
        error: 'Not Found'
    });
});

if (process.env.NODE_ENV !== 'test') {
    const PORT = process.env.PORT || 3000;
    app.listen(PORT, () => {
        console.log(`Server is running on http://localhost:${PORT}`);
        console.log('Available routes:');
        console.log('GET / - Server status');
        console.log('GET /test - Basic test');
        console.log('GET /auth/test - Auth test');
        console.log('POST /auth/register - Register');
        console.log('POST /auth/login - Login');
    });
}

module.exports = app;




