import React, { useContext, useEffect, useState } from 'react';

import { AuthContext } from '../contexts/AuthContext';
import { Game } from '../types/game';
import { useParams } from 'react-router-dom';

interface BetOption {
  label: string;
  odds: number;
}

const BetPage: React.FC = () => {
  const { gameId } = useParams<{ gameId: string }>();
  const [game, setGame] = useState<Game | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const { user } = useContext(AuthContext);

  // New state for bet selection, stake amount, and bet placement loading indicator
  const [selectedBet, setSelectedBet] = useState<BetOption | null>(null);
  const [stake, setStake] = useState<number>(0);
  const [betLoading, setBetLoading] = useState<boolean>(false);

  useEffect(() => {
    if (gameId) {
      fetch(`http://localhost:3000/games/${gameId}`, {
        method: 'GET',
        headers: {
          'Authorization': `Bearer ${user?.token}`,
          'Content-Type': 'application/json',
        },
      })
        .then((res) => {
          if (!res.ok) {
            throw new Error('Failed to fetch game details');
          }
          return res.json();
        })
        .then((data: Game) => {
          setGame(data);
          setLoading(false);
        })
        .catch((err) => {
          setError(err.message);
          setLoading(false);
        });
    }
  }, [gameId, user]);

  if (loading) {
    return <div>Loading game details...</div>;
  }

  if (error) {
    return <div>Error: {error}</div>;
  }

  if (!game) {
    return <div>No game found</div>;
  }

  // Calculate potential winnings
  const potentialWinnings = selectedBet ? (stake * selectedBet.odds).toFixed(2) : '--';

  // Handler for confirming the bet
  const handleConfirmBet = async () => {
    if (!selectedBet) {
      alert('Please select a bet option.');
      return;
    }
    if (stake <= 0) {
      alert('Please enter a valid stake amount.');
      return;
    }

    // Set bet loading to true to show loading text
    setBetLoading(true);

    // Map the selected label to rails backend bet_type.
    const betTypeMapping: { [key: string]: string } = {
      [`${game.home_team} Win`]: 'home',
      'Draw': 'draw',
      [`${game.away_team} Win`]: 'away',
    };

    const betType = betTypeMapping[selectedBet.label];

    // Build the payload to send
    const payload = {
      bet: {
        game_id: game.id,
        amount: stake,
        odds: selectedBet.odds,
        bet_type: betType,
      }
    };

    try {
      const response = await fetch('http://127.0.0.1:3000/bets', {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${user?.token}`,
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(payload),
      });

      if (!response.ok) {
        throw new Error('Failed to place bet');
      }

      const data = await response.json();
      console.log('Bet placed successfully:', data);
      alert('Bet placed successfully!');
    } catch (err) {
      console.error(err);
      alert('Error placing bet.');
    } finally {
      // Reset the bet loading state once done
      setBetLoading(false);
    }
  };

  return (
    <div className="p-6">
      <h1 className="text-2xl font-bold mb-4">Place Your Bet</h1>
      <div className="border rounded-lg p-4 shadow-md bg-white">
        <h2 className="font-bold text-lg">
          {game.home_team} vs {game.away_team}
        </h2>
        <p className="text-gray-600">Score: {game.score}</p>
        <p className="text-gray-500">Minute: {game.minute}'</p>
        <p className="text-sm text-gray-700">Status: {game.status}</p>

        <div className="mt-4">
          <h3 className="text-lg font-semibold">Bet on Match Result</h3>
          <div className="grid grid-cols-3 gap-4 mt-2">
            <button 
              onClick={() => setSelectedBet({ label: `${game.home_team} Win`, odds: game.odds?.home_win || 0 })}
              className={`border p-2 rounded ${selectedBet?.label === `${game.home_team} Win` ? 'bg-blue-500 text-white' : ''}`}>
              {game.home_team} Win @ {game.odds?.home_win.toFixed(2)}
            </button>
            <button 
              onClick={() => setSelectedBet({ label: 'Draw', odds: game.odds?.draw || 0 })}
              className={`border p-2 rounded ${selectedBet?.label === 'Draw' ? 'bg-blue-500 text-white' : ''}`}>
              Draw @ {game.odds?.draw.toFixed(2)}
            </button>
            <button 
              onClick={() => setSelectedBet({ label: `${game.away_team} Win`, odds: game.odds?.away_win || 0 })}
              className={`border p-2 rounded ${selectedBet?.label === `${game.away_team} Win` ? 'bg-blue-500 text-white' : ''}`}>
              {game.away_team} Win @ {game.odds?.away_win.toFixed(2)}
            </button>
          </div>
        </div>

        <div className="mt-4">
          <h3 className="text-lg font-semibold">Your Bet Slip</h3>
          <div className="border p-2 rounded mt-2">
            <p>
              Selected Bet: <strong>{selectedBet ? selectedBet.label : 'None'}</strong>
            </p>
            <p>
              Odds: <strong>{selectedBet ? selectedBet.odds : '--'}</strong>
            </p>
            <p>
              Stake: $
              <input
                type="number"
                value={stake}
                onChange={(e) => setStake(Number(e.target.value))}
                className="border rounded w-20 ml-2 p-1"
                placeholder="Amount"
              />
            </p>
            <p>
              Potential Winnings: $<span>{potentialWinnings}</span>
            </p>
            <button 
              onClick={handleConfirmBet}
              disabled={betLoading}
              className={`mt-2 p-2 rounded ${betLoading ? 'bg-gray-500 text-white' : 'bg-blue-500 text-white'}`}>
              {betLoading ? 'Placing Bet...' : 'Confirm Bet'}
            </button>
          </div>
        </div>
      </div>
    </div>
  );
};

export default BetPage;
