const WebSocket = require('ws');
const Redis = require('ioredis');
const express = require('express');
const http = require('http');

const app = express();
const server = http.createServer(app);
const wss = new WebSocket.Server({ server });

const redis = new Redis({
  host: process.env.REDIS_HOST || '127.0.0.1',
  port: process.env.REDIS_PORT || 6379
});

// Health check endpoint
app.get('/health', (req, res) => {
  const health = {
    status: 'ok',
    timestamp: new Date().toISOString(),
    websocket: wss.clients.size >= 0,
    redis: redis.status === 'ready'
  };
  res.json(health);
});

wss.on('connection', ws => {
  console.log('Client connected');

  // Subscribe to Redis channels
  redis.subscribe('game_updates', 'leaderboard_updates', (err, count) => {
    if (err) {
      console.error('Failed to subscribe:', err);
    } else {
      console.log(`Subscribed to ${count} channel(s)`);
    }
  });

  ws.on('message', message => {
    console.log('received: %s', message);
  });

  ws.on('close', () => {
    console.log('Client disconnected');
  });
});

redis.on('message', (channel, message) => {
  console.log(`Received ${message} from ${channel}`);
  wss.clients.forEach(client => {
    if (client.readyState === WebSocket.OPEN) {
      client.send(JSON.stringify({ channel, message }));
    }
  });
});

// Error handling
redis.on('error', (err) => {
  console.error('Redis error:', err);
});

wss.on('error', (err) => {
  console.error('WebSocket server error:', err);
});

// Start server
const PORT = process.env.PORT || 3001;
server.listen(PORT, () => {
  console.log(`WebSocket server started on port ${PORT}`);
});

// Graceful shutdown
process.on('SIGTERM', () => {
  console.log('SIGTERM signal received: closing HTTP server');
  server.close(() => {
    console.log('HTTP server closed');
    redis.quit();
    process.exit(0);
  });
});
