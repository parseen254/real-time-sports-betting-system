import React, { useContext, useEffect, useState } from 'react';

import { AuthContext } from '../contexts/AuthContext';

interface Bet {
  id: number;
  game_id: number;
  amount: string;
  odds: number;
  potential_payout: string;
  status: string;
  created_at: string;
  bet_type: string;
}

const BetHistory: React.FC = () => {
  const [bets, setBets] = useState<Bet[]>([]);
  const [loading, setLoading] = useState<boolean>(true);
  const [error, setError] = useState<string | null>(null);

  const { user } = useContext(AuthContext);

  useEffect(() => {
    const fetchBetHistory = async () => {
      try {
        const response = await fetch('http://127.0.0.1:3000/betshistory', {
          method: 'GET',
          headers: {
            'Authorization': `Bearer ${user?.token}`,
            'Content-Type': 'application/json',
          },
        });

        if (!response.ok) {
          throw new Error('Failed to fetch bet history');
        }

        const data: Bet[] = await response.json();
        setBets(data);
      } catch (err) {
        setError((err as Error).message);
      } finally {
        setLoading(false);
      }
    };

    fetchBetHistory();
  }, [user]);

  const formatDate = (dateString: string | undefined): string => {
    if (!dateString) return "Invalid Date"; // Handle missing dates

    const date = new Date(dateString); // Auto-parses valid date formats

    if (isNaN(date.getTime())) return "Invalid Date"; // Handle incorrect formats

    return new Intl.DateTimeFormat("en-US", {
      weekday: "short",
      year: "numeric",
      month: "long",
      day: "numeric",
      hour: "2-digit",
      minute: "2-digit",
      second: "2-digit",
      hour12: true,
    }).format(date);
  };

  if (loading) return <p>Loading bet history...</p>;
  if (error) return <p>Error: {error}</p>;

  return (
    <div>
      <h1>Bet History</h1>
      {bets.length === 0 ? (
        <p>No bets found.</p>
      ) : (
        <table className="bet-history-table">
          <thead>
            <tr>
              <th>Game ID</th>
              <th>Amount</th>
              <th>Odds</th>
              <th>Potential Payout</th>
              <th>Status</th>
              <th>Bet Type</th>
              <th>Date</th>
            </tr>
          </thead>
          <tbody>
            {bets.map((bet) => (
              <tr key={bet.id}>
                <td>{bet.game_id}</td>
                <td>${bet.amount}</td>
                <td>{bet.odds.toFixed(2)}</td>
                <td>${bet.potential_payout}</td>
                <td className={bet.status === 'won' ? 'status-won' : bet.status === 'open' ? 'status-open' : ''}>
                  {bet.status}
                </td>
                <td>{bet.bet_type}</td>
                <td>{formatDate(bet.created_at)}</td>
              </tr>
            ))}
          </tbody>
        </table>
      )}
    </div>
  );
};

export default BetHistory;
