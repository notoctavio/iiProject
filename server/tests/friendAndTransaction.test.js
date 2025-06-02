const request = require('supertest');
const mongoose = require('mongoose');
const app = require('../server');
const User = require('../models/User');
const FriendRequest = require('../models/FriendRequest');
const Transaction = require('../models/Transaction');

describe('Friend and Transaction API Tests', () => {
    let testUser1;
    let testUser2;
    let testUser3;
    let testUser1Token;
    let testUser2Token;

    beforeAll(async () => {
        // Connect to test database
        await mongoose.connect(process.env.MONGODB_URI_TEST || 'mongodb://localhost:27017/splitwise_test');
        
        // Clear all collections
        await User.deleteMany({});
        await FriendRequest.deleteMany({});
        await Transaction.deleteMany({});

        // Register test users via API
        const reg1 = await request(app)
            .post('/auth/register')
            .send({
                FullName: 'Test User 1',
                Email: 'test1@example.com',
                Password: 'password123',
                Plan: 'Free'
            });
        testUser1Token = reg1.body.token;
        testUser1 = await User.findOne({ email: 'test1@example.com' });

        const reg2 = await request(app)
            .post('/auth/register')
            .send({
                FullName: 'Test User 2',
                Email: 'test2@example.com',
                Password: 'password123',
                Plan: 'Free'
            });
        testUser2Token = reg2.body.token;
        testUser2 = await User.findOne({ email: 'test2@example.com' });

        const reg3 = await request(app)
            .post('/auth/register')
            .send({
                FullName: 'Test User 3',
                Email: 'test3@example.com',
                Password: 'password123',
                Plan: 'Free'
            });
        testUser3 = await User.findOne({ email: 'test3@example.com' });
    });

    afterAll(async () => {
        await mongoose.connection.close();
    });

    describe('Friend Management', () => {
        let pendingRequest;

        beforeEach(async () => {
            // Clear friend requests before each test in this suite
            await FriendRequest.deleteMany({});

            // Directly create a pending friend request with ObjectId pentru consistență
            pendingRequest = await FriendRequest.create({
                sender: testUser1._id, // Fără .toString()
                receiver: testUser2._id, // Fără .toString()
                status: 'pending'
            });
        });

        test('GET /friends/users - Should get all users excluding current user and friends', async () => {
            const response = await request(app)
                .get('/friends/users')
                .set('Authorization', `Bearer ${testUser1Token}`);

            expect(response.status).toBe(200);
            expect(Array.isArray(response.body)).toBe(true);
            expect(response.body.length).toBe(2); // Should see testUser2 and testUser3
        });

        test('POST /friends/request/:userId - Should send friend request', async () => {
            // Send a friend request from testUser1 to testUser3 (not already requested/friended)
            const response = await request(app)
                .post(`/friends/request/${testUser3._id}`)
                .set('Authorization', `Bearer ${testUser1Token}`);

            expect(response.status).toBe(200);
            expect(response.body.sender.toString()).toBe(testUser1._id.toString());
            expect(response.body.receiver.toString()).toBe(testUser3._id.toString());
            expect(response.body.status).toBe('pending');
        });

        test('GET /friends/requests - Should get pending friend requests', async () => {
            const response = await request(app)
                .get('/friends/requests')
                .set('Authorization', `Bearer ${testUser2Token}`);

            expect(response.status).toBe(200);
            expect(Array.isArray(response.body)).toBe(true);
            // Expecting the one pending request created in beforeEach
            expect(response.body.length).toBe(1);
            expect(response.body[0].sender._id.toString()).toBe(testUser1._id.toString());
        });

        // Testele pentru acceptarea cererii de prietenie și listarea prietenilor sunt eliminate conform solicitării.
    });

    describe('Transaction Management', () => {
        let testTransaction;

        beforeAll(async () => {
            // Ensure users are friends before testing transactions
            await User.findByIdAndUpdate(testUser1._id, { $addToSet: { friends: testUser2._id } });
            await User.findByIdAndUpdate(testUser2._id, { $addToSet: { friends: testUser1._id } });
        });

        beforeEach(async () => {
            // Create a test transaction
            testTransaction = await Transaction.create({
                description: 'Test Transaction',
                amount: 100,
                splitType: '50-50',
                payer: testUser1._id,
                payee: testUser2._id,
                status: 'pending'
            });
        });

        test('POST /friends/transaction - Should create new transaction', async () => {
            const transactionData = {
                friendId: testUser2._id,
                description: 'Lunch',
                amount: 100,
                splitType: '50-50'
            };

            const response = await request(app)
                .post('/friends/transaction')
                .set('Authorization', `Bearer ${testUser1Token}`)
                .send(transactionData);

            expect(response.status).toBe(200);
            expect(response.body.description).toBe('Lunch');
            expect(response.body.amount).toBe(100);
            expect(response.body.splitType).toBe('50-50');
            expect(response.body.status).toBe('pending');
        });

        test('POST /friends/transaction - Should validate friend relationship', async () => {
            const transactionData = {
                friendId: testUser3._id, // Not a friend
                description: 'Lunch',
                amount: 100,
                splitType: '50-50'
            };

            const response = await request(app)
                .post('/friends/transaction')
                .set('Authorization', `Bearer ${testUser1Token}`)
                .send(transactionData);

            expect(response.status).toBe(400);
            expect(response.body.error).toBe('User is not your friend');
        });

        test('POST /friends/transaction - Should validate split percentage for custom split', async () => {
            const transactionData = {
                friendId: testUser2._id,
                description: 'Lunch',
                amount: 100,
                splitType: 'custom',
                splitPercentage: 150 // Invalid percentage
            };

            const response = await request(app)
                .post('/friends/transaction')
                .set('Authorization', `Bearer ${testUser1Token}`)
                .send(transactionData);

            expect(response.status).toBe(400);
            expect(response.body.error).toBe('Invalid split percentage');
        });

        // Need to add tests for GET /friends/transactions and PUT /friends/transaction/:transactionId
    });
}); 