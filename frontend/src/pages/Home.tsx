import React, { useEffect, useState } from 'react';

import { Game } from '../types/game';
import LiveGame from '../components/LiveGame';
import { setupWebSocket } from '../services/websocket';

const Home: React.FC = () => {
  const [games, setGames] = useState<Game[]>([]);
  
  useEffect(() => {
    const socket = setupWebSocket(
      (updatedGame) => {
        setGames((prevGames) => {
          const gameIndex = prevGames.findIndex(g => g.game_id === updatedGame.game_id);
          if (gameIndex !== -1) {
            const newGames = [...prevGames];
            newGames[gameIndex] = updatedGame;
            return newGames;
          } else {
            return [...prevGames, updatedGame];
          }
        });
      },
      (initialGames) => {
        setGames(initialGames);
      }
    );

    return () => socket.close();
  }, []);

  return (
    <div className="p-6">
      <h1 className="text-2xl font-bold mb-4">Live Games</h1>
      <div className="grid gap-4">
        {games.length > 0 ? (
          games.map(game => <LiveGame key={game.game_id} game={game} />)
        ) : (
          <p>Loading...</p>
        )}
      </div>
    </div>
  );
};

export default Home;
