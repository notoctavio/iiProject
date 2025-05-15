const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const User = require('../models/User');

// Helper function to standardize plan name
function standardizePlan(plan) {
    if (!plan) return 'Free';
    const planMap = {
        'free': 'Free',
        'pro': 'Pro',
        'family': 'Family'
    };
    return planMap[plan.toLowerCase()] || 'Free';
}

// Helper function to validate email format
function isValidEmail(email) {
    // Validare simplă pentru formatul text@text
    const emailRegex = /^[^\s@]+@[^\s@]+$/;
    return emailRegex.test(email);
}

// Helper function to validate password strength
function isStrongPassword(password) {
    return password.length >= 6; // Minim 6 caractere pentru parolă
}

// Helper function to generate JWT token
function generateToken(userId) {
    return jwt.sign(
        { userId },
        process.env.JWT_SECRET || 'your-secret-key',
        { expiresIn: '24h' }
    );
}

async function register(req, res) {
    console.log('Register attempt with body:', req.body);
    const { FullName, Email, Password, Plan } = req.body;

    try {
        console.log('Validating fields...');
        // Validare input
        if (!FullName || !Email || !Password) {
            console.log('Missing required fields:', { FullName, Email, Password });
            return res.status(400).json({ 
                error: "All fields are required.",
                details: {
                    fullName: !FullName ? "Full name is required" : null,
                    email: !Email ? "Email is required" : null,
                    password: !Password ? "Password is required" : null
                }
            });
        }

        console.log('Validating email format...');
        if (!isValidEmail(Email)) {
            console.log('Invalid email format:', Email);
            return res.status(400).json({ 
                error: "Invalid email format",
                details: "Email must be in format: text@text"
            });
        }

        console.log('Validating password strength...');
        if (!isStrongPassword(Password)) {
            console.log('Password too short:', Password.length);
            return res.status(400).json({ 
                error: "Password is too short",
                details: "Password must be at least 6 characters long"
            });
        }

        console.log('Checking for existing user...');
        // Check if user already exists
        const existingUser = await User.findOne({ email: Email.toLowerCase() });
        if (existingUser) {
            console.log('User already exists with email:', Email);
            return res.status(400).json({ error: "Email already registered." });
        }

        console.log('Hashing password...');
        // Hash password
        const passwordHash = await bcrypt.hash(Password, 12);

        console.log('Creating new user...');
        // Create user
        const user = await User.create({
            fullName: FullName,
            email: Email.toLowerCase(),
            passwordHash: passwordHash,
            plan: standardizePlan(Plan)
        });

        console.log('Generating token...');
        // Generate token
        const token = generateToken(user._id);

        console.log('Registration successful!');
        // Return success without sensitive data
        res.status(201).json({ 
            message: "User registered successfully.",
            user: {
                fullName: user.fullName,
                email: user.email,
                plan: user.plan
            },
            token
        });
    } catch (err) {
        console.error('Registration error:', err);
        res.status(500).json({ 
            error: "Registration failed.",
            details: err.message 
        });
    }
}

async function login(req, res) {
    const { Email, Password } = req.body;

    try {
        if (!Email || !Password) {
            return res.status(400).json({ error: 'Email and password are required.' });
        }

        // Find user by email (case insensitive)
        const user = await User.findOne({ email: Email.toLowerCase() });
        if (!user) {
            return res.status(401).json({ error: 'Invalid credentials' });
        }

        const passwordMatch = await bcrypt.compare(Password, user.passwordHash);
        if (!passwordMatch) {
            return res.status(401).json({ error: 'Invalid credentials' });
        }

        // Generate token
        const token = generateToken(user._id);

        // Return success without sensitive data
        res.status(200).json({ 
            message: 'Login successful', 
            user: {
                fullName: user.fullName,
                email: user.email,
                plan: user.plan
            },
            token
        });
    } catch (err) {
        res.status(500).json({ error: 'Authentication failed' });
    }
}

module.exports = {
    register,
    login
}; 