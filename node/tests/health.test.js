const request = require('supertest');
const WebSocket = require('ws');
const http = require('http');
const express = require('express');

const app = express();
const server = http.createServer(app);
const wss = new WebSocket.Server({ server });

// Mock Redis
jest.mock('ioredis', () => {
  return jest.fn().mockImplementation(() => {
    return {
      status: 'ready',
      subscribe: jest.fn(),
      on: jest.fn(),
      ping: jest.fn().mockResolvedValue('PONG')
    };
  });
});

// Import server file after mocking dependencies
require('../server');

describe('Health Check Endpoint', () => {
  beforeAll((done) => {
    server.listen(3001, done);
  });

  afterAll((done) => {
    server.close(done);
  });

  it('should return 200 OK with correct health status', async () => {
    const response = await request(server)
      .get('/health')
      .expect('Content-Type', /json/)
      .expect(200);

    expect(response.body).toEqual(expect.objectContaining({
      status: 'ok',
      websocket: true,
      redis: true
    }));
    expect(response.body.timestamp).toBeDefined();
  });

  it('should report correct WebSocket status', async () => {
    // Create a WebSocket connection
    const ws = new WebSocket('ws://localhost:3001');
    
    await new Promise(resolve => ws.on('open', resolve));

    const response = await request(server)
      .get('/health')
      .expect(200);

    expect(response.body.websocket).toBe(true);

    ws.close();
  });

  it('should handle multiple concurrent requests', async () => {
    const requests = Array(5).fill().map(() => 
      request(server).get('/health').expect(200)
    );

    const responses = await Promise.all(requests);
    responses.forEach(response => {
      expect(response.body.status).toBe('ok');
    });
  });
});
