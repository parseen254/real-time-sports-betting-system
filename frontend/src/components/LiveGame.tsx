import React from 'react';
import { Game } from '../types/game';
import { Link } from 'react-router-dom';

interface LiveGameProps {
  game: Game;
}

const LiveGame: React.FC<LiveGameProps> = ({ game }) => {

  return (
    <div className="border rounded-lg p-4 shadow-md bg-white">
      <h2 className="font-bold text-lg">{game.home_team} vs {game.away_team}</h2>
      <p className="text-gray-600">Score: {game.score}</p>
      <p className="text-gray-500">Minute: {game.minute}</p>
      <p className="text-sm text-gray-700">Status: {game.status}</p>

      <div className="mt-2">
        <Link to={`/bet/${game.game_id}`}>
          <button className="bg-blue-500 hover:bg-blue-600 text-white font-bold py-2 px-4 rounded">
            Place Bet
          </button>
        </Link>
      </div>
      
    </div>
  );
};

export default LiveGame;
