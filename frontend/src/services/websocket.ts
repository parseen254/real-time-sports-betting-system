import { Game } from '../types/game';

const WS_URL = process.env.REACT_APP_WS_URL || 'ws://localhost:8080';

export const setupWebSocket = (
  onUpdate: (game: Game) => void,
  onInitialize: (games: Game[]) => void
) => {
  const socket = new WebSocket(WS_URL);

  socket.onopen = () => {
    console.log('WebSocket connected');
  };

  socket.onmessage = (event) => {
    try {
      const data = JSON.parse(event.data);
      
      // If the server sends an array, it's the initial game list
      if (Array.isArray(data)) {
        onInitialize(data);
      } else {
        // Otherwise, it's a single game update
        onUpdate(data);
      }
    } catch (error) {
      console.error('WebSocket message error:', error);
    }
  };

  socket.onclose = () => {
    console.log('WebSocket disconnected, attempting to reconnect...');
    setTimeout(() => setupWebSocket(onUpdate, onInitialize), 5000); // Auto-reconnect
  };

  socket.onerror = (error) => {
    console.error('WebSocket encountered an error:', error);
  };

  return socket;
};
