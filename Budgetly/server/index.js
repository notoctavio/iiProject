const express = require('express');
const cors = require('cors');

const app = express();
app.use(cors());
app.use(express.json()); // Parsează JSON-ul din request-uri

// Endpoint pentru login
app.post('/api/login', (req, res) => {
    const { username, password } = req.body;

    // Exemplu simplu de validare (într-un caz real, folosește o bază de date)
    if (username === 'admin@gmail.com' && password === 'password1234') {
        return res.status(200).json({ message: 'Login successful', token: 'fake-jwt-token' });
    } else {
        return res.status(401).json({ message: 'Invalid credentials' });
    }
});

const PORT = 3000;
app.listen(PORT, () => {
    console.log(`Server running on http://localhost:${PORT}`);
});