const bcrypt = require('bcrypt');
const User = require('../models/User');

async function register(req, res) {
    const { FullName, Email, Password, Plan } = req.body;

    try {
        if (!FullName || !Email || !Password) {
            return res.status(400).json({ error: "FullName, Email and Password are required." });
        }

        // Check if user already exists
        const existingUser = await User.findOne({ email: Email.toLowerCase() });
        if (existingUser) {
            return res.status(400).json({ error: "Email already registered." });
        }

        // Hash password
        const passwordHash = await bcrypt.hash(Password, 10);

        // Create user
        const user = await User.create({
            fullName: FullName,
            email: Email.toLowerCase(),
            passwordHash,
            plan: Plan || 'Free'
        });

        res.status(201).json({ 
            message: "User registered successfully.",
            user: user.toJSON()
        });
    } catch (err) {
        console.error("Register error:", err);
        res.status(500).json({ error: "Registration failed.", details: err.message });
    }
}

async function login(req, res) {
    const { Email, Password } = req.body;

    try {
        if (!Email || !Password) {
            return res.status(400).json({ error: 'Email and password are required.' });
        }

        const user = await User.findOne({ email: Email.toLowerCase() });
        if (!user) {
            return res.status(401).json({ error: 'Invalid email or password' });
        }

        const passwordMatch = await bcrypt.compare(Password, user.passwordHash);
        if (passwordMatch) {
            res.status(200).json({ 
                message: 'Login successful', 
                user: user.toJSON()
            });
        } else {
            res.status(401).json({ error: 'Invalid email or password' });
        }
    } catch (err) {
        console.error('Login error:', err);
        res.status(500).json({ error: 'Internal server error', details: err.message });
    }
}

module.exports = {
    register,
    login
}; 