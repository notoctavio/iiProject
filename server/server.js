const express = require('express');
const cors = require('cors');
require('dotenv').config();
const authRoutes = require('./routes/authRoutes');

const app = express();

// Basic middleware
app.use(cors());
app.use(express.json());

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

// Error handling
app.use((err, req, res, next) => {
    console.error(err.stack);
    res.status(500).json({ error: 'Something broke!' });
});

// 404 handler - keep this last
app.use((req, res) => {
    res.status(404).json({ 
        error: 'Not Found',
        path: req.path,
        method: req.method
    });
});

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




