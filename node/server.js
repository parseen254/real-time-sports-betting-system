const WebSocket = require('ws');
const Redis = require('ioredis');

const redis = new Redis({
  host: process.env.REDIS_HOST || '127.0.0.1',
  port: process.env.REDIS_PORT || 6379
});

const wss = new WebSocket.Server({ port: 3001 });

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

console.log('WebSocket server started on port 3001');
