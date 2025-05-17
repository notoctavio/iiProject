const request = require('supertest');
const mongoose = require('mongoose');
const { MongoMemoryServer } = require('mongodb-memory-server');
const app = require('../server'); // Make sure to export app from server.js
const User = require('../models/User');

let mongoServer;

beforeAll(async () => {
    mongoServer = await MongoMemoryServer.create();
    const mongoUri = mongoServer.getUri();
    
    // Deconectează orice conexiune existentă
    if (mongoose.connection.readyState !== 0) {
        await mongoose.disconnect();
    }
    
    await mongoose.connect(mongoUri, {
        useNewUrlParser: true,
        useUnifiedTopology: true
    });
});

afterAll(async () => {
    if (mongoose.connection.readyState !== 0) {
        await mongoose.disconnect();
    }
    if (mongoServer) {
        await mongoServer.stop();
    }
});

beforeEach(async () => {
    // Curăță baza de date înainte de fiecare test
    if (mongoose.connection.readyState !== 0) {
        await User.deleteMany({});
    }
});

describe('Authentication Tests', () => {
    describe('POST /auth/register', () => {
        it('should register a new user successfully', async () => {
            const res = await request(app)
                .post('/auth/register')
                .send({
                    FullName: "Test User",
                    Email: "test@example.com",
                    Password: "test1234",
                    Plan: "Free"
                });

            expect(res.statusCode).toBe(201);
            expect(res.body).toHaveProperty('token');
            expect(res.body.user).toHaveProperty('fullName', 'Test User');
            expect(res.body.user).toHaveProperty('email', 'test@example.com');
            expect(res.body.user).toHaveProperty('plan', 'Free');
        });

        it('should not register user with existing email', async () => {
            // First registration
            await request(app)
                .post('/auth/register')
                .send({
                    FullName: "Test User",
                    Email: "test@example.com",
                    Password: "test1234",
                    Plan: "Free"
                });

            // Try to register with same email
            const res = await request(app)
                .post('/auth/register')
                .send({
                    FullName: "Another User",
                    Email: "test@example.com",
                    Password: "different123",
                    Plan: "Pro"
                });

            expect(res.statusCode).toBe(400);
            expect(res.body).toHaveProperty('error', 'Email already registered.');
        });

        it('should not register user with invalid email format', async () => {
            const res = await request(app)
                .post('/auth/register')
                .send({
                    FullName: "Test User",
                    Email: "invalid-email",
                    Password: "test1234",
                    Plan: "Free"
                });

            expect(res.statusCode).toBe(400);
            expect(res.body.error).toBe('Invalid email format');
        });

        it('should not register user with short password', async () => {
            const res = await request(app)
                .post('/auth/register')
                .send({
                    FullName: "Test User",
                    Email: "test@example.com",
                    Password: "123",
                    Plan: "Free"
                });

            expect(res.statusCode).toBe(400);
            expect(res.body.error).toBe('Password is too short');
        });

        it('should standardize plan name', async () => {
            const res = await request(app)
                .post('/auth/register')
                .send({
                    FullName: "Test User",
                    Email: "test@example.com",
                    Password: "test1234",
                    Plan: "free"
                });

            expect(res.statusCode).toBe(201);
            expect(res.body.user.plan).toBe('Free');
        });
    });

    describe('POST /auth/login', () => {
        beforeEach(async () => {
            // Create a test user before each login test
            await request(app)
                .post('/auth/register')
                .send({
                    FullName: "Test User",
                    Email: "test@example.com",
                    Password: "test1234",
                    Plan: "Free"
                });
        });

        it('should login successfully with correct credentials', async () => {
            const res = await request(app)
                .post('/auth/login')
                .send({
                    Email: "test@example.com",
                    Password: "test1234"
                });

            expect(res.statusCode).toBe(200);
            expect(res.body).toHaveProperty('token');
            expect(res.body.user).toHaveProperty('email', 'test@example.com');
        });

        it('should not login with incorrect password', async () => {
            const res = await request(app)
                .post('/auth/login')
                .send({
                    Email: "test@example.com",
                    Password: "wrongpassword"
                });

            expect(res.statusCode).toBe(401);
            expect(res.body.error).toBe('Invalid credentials');
        });

        it('should not login with non-existent email', async () => {
            const res = await request(app)
                .post('/auth/login')
                .send({
                    Email: "nonexistent@example.com",
                    Password: "test1234"
                });

            expect(res.statusCode).toBe(401);
            expect(res.body.error).toBe('Invalid credentials');
        });

        it('should not login with missing credentials', async () => {
            const res = await request(app)
                .post('/auth/login')
                .send({});

            expect(res.statusCode).toBe(400);
            expect(res.body.error).toBe('Email and password are required.');
        });
    });
}); 