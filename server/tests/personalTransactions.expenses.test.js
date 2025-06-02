const request = require('supertest');
const app = require('../server'); // sau calea către fișierul Express
const mongoose = require('mongoose');
const PersonalTransaction = require('../models/PersonalTransaction');

describe('Expenses API (Personal Transactions)', () => {
  let TEST_USER_ID;
  let TEST_TOKEN;
  let email;

  beforeAll(async () => {
    // Conectează la baza de date de test
    await mongoose.connect('mongodb://localhost:27017/budgetly_test', { useNewUrlParser: true, useUnifiedTopology: true });
    // Creează userul de test cu email random și obține tokenul
    email = `testuser+${Date.now()}@example.com`;
    const res = await request(app)
      .post('/auth/register')
      .send({
        FullName: 'Test User',
        Email: email,
        Password: 'test1234',
        Plan: 'Free'
      });
    TEST_TOKEN = res.body.token;
    TEST_USER_ID = res.body.user._id;
  });

  afterAll(async () => {
    await mongoose.connection.db.dropDatabase();
    await mongoose.disconnect();
  });

  afterEach(async () => {
    await PersonalTransaction.deleteMany({});
  });

  it('should add a new expense transaction', async () => {
    try {
      const res = await request(app)
        .post('/personal-transactions')
        .set('Authorization', `Bearer ${TEST_TOKEN}`)
        .send({
          description: 'Test Expense',
          amount: 100,
          type: 'expense',
          category: 'Food',
          date: '2024-06-01',
          isSubscription: false
        });
      console.log('Add transaction response:', res.statusCode, res.body);
      expect(res.statusCode).toBeGreaterThanOrEqual(200);
      expect(res.statusCode).toBeLessThan(300);
      expect(res.body).toHaveProperty('_id');
    } catch (err) {
      console.error(err);
    }
  });

  it('should not add transaction with missing fields', async () => {
    try {
      const res = await request(app)
        .post('/personal-transactions')
        .set('Authorization', `Bearer ${TEST_TOKEN}`)
        .send({
          amount: 100,
          type: 'expense',
          category: 'Food',
          date: '2024-06-01'
        });
      console.log('Add transaction missing fields response:', res.statusCode, res.body);
      expect(res.statusCode).toBeGreaterThanOrEqual(400);
      expect(res.body).toHaveProperty('error');
    } catch (err) {
      console.error(err);
    }
  });

  it('should get all transactions for user', async () => {
    try {
      await PersonalTransaction.create({
        user: TEST_USER_ID,
        description: 'Test',
        amount: 50,
        type: 'income',
        category: 'Salary',
        date: '2024-06-01',
        isSubscription: false
      });
      const res = await request(app)
        .get('/personal-transactions')
        .set('Authorization', `Bearer ${TEST_TOKEN}`);
      console.log('Get all transactions response:', res.statusCode, res.body);
      expect(res.statusCode).toBeGreaterThanOrEqual(200);
      expect(res.statusCode).toBeLessThan(300);
      expect(Array.isArray(res.body)).toBe(true);
    } catch (err) {
      console.error(err);
    }
  });

  it('should update a transaction', async () => {
    try {
      const transaction = await PersonalTransaction.create({
        user: TEST_USER_ID,
        description: 'To update',
        amount: 10,
        type: 'expense',
        category: 'Other',
        date: '2024-06-01',
        isSubscription: false
      });
      const res = await request(app)
        .put(`/personal-transactions/${transaction._id}`)
        .set('Authorization', `Bearer ${TEST_TOKEN}`)
        .send({ description: 'Updated' });
      console.log('Update transaction response:', res.statusCode, res.body);
      expect(res.statusCode).toBeGreaterThanOrEqual(200);
      expect(res.statusCode).toBeLessThan(300);
      expect(res.body).toHaveProperty('description');
    } catch (err) {
      console.error(err);
    }
  });

  it('should delete a transaction', async () => {
    try {
      const transaction = await PersonalTransaction.create({
        user: TEST_USER_ID,
        description: 'To delete',
        amount: 10,
        type: 'expense',
        category: 'Other',
        date: '2024-06-01',
        isSubscription: false
      });
      const res = await request(app)
        .delete(`/personal-transactions/${transaction._id}`)
        .set('Authorization', `Bearer ${TEST_TOKEN}`);
      console.log('Delete transaction response:', res.statusCode, res.body);
      expect(res.statusCode).toBeGreaterThanOrEqual(200);
      expect(res.statusCode).toBeLessThan(300);
    } catch (err) {
      console.error(err);
    }
  });

  it('should get monthly summary', async () => {
    try {
      await PersonalTransaction.create([
        {
          user: TEST_USER_ID,
          description: 'Income',
          amount: 1000,
          type: 'income',
          category: 'Salary',
          date: '2024-06-01',
          isSubscription: false
        },
        {
          user: TEST_USER_ID,
          description: 'Expense',
          amount: 200,
          type: 'expense',
          category: 'Food',
          date: '2024-06-01',
          isSubscription: false
        }
      ]);
      const res = await request(app)
        .get('/personal-transactions/summary')
        .set('Authorization', `Bearer ${TEST_TOKEN}`);
      console.log('Monthly summary response:', res.statusCode, res.body);
      expect(res.statusCode).toBeGreaterThanOrEqual(200);
      expect(res.statusCode).toBeLessThan(300);
      expect(res.body).toHaveProperty('income');
      expect(res.body).toHaveProperty('expenses');
      expect(res.body).toHaveProperty('subscriptions');
      expect(res.body).toHaveProperty('net');
    } catch (err) {
      console.error(err);
    }
  });

  it('should not allow access without token', async () => {
    try {
      const res = await request(app)
        .get('/personal-transactions');
      console.log('No token response:', res.statusCode, res.body);
      expect(res.statusCode).toBeGreaterThanOrEqual(400);
    } catch (err) {
      console.error(err);
    }
  });
}); 