const request = require('supertest');
const app = require('../server');

describe('Server Basic Functionality Tests', () => {
    test('GET / - Should return server status', async () => {
        const response = await request(app)
            .get('/');

        expect(response.status).toBe(200);
        expect(response.body).toHaveProperty('message', 'Server is running');
    });

    test('GET /test - Should return test route message', async () => {
        const response = await request(app)
            .get('/test');

        expect(response.status).toBe(200);
        expect(response.body).toHaveProperty('message', 'Test route working');
    });

    test('GET /nonexistent - Should return 404 for non-existent routes', async () => {
        const response = await request(app)
            .get('/nonexistent');

        expect(response.status).toBe(404);
        expect(response.body).toHaveProperty('error', 'Not Found');
    });

    test('Should handle CORS preflight requests', async () => {
        const response = await request(app)
            .options('/')
            .set('Origin', 'http://localhost:5173')
            .set('Access-Control-Request-Method', 'GET');

        expect(response.status).toBe(204);
        expect(response.headers['access-control-allow-origin']).toBe('http://localhost:5173');
        expect(response.headers['access-control-allow-methods']).toContain('GET');
    });
}); 