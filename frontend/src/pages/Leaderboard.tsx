import React, { useContext, useEffect, useState } from 'react';

import { AuthContext } from '../contexts/AuthContext';

interface LeaderboardEntry {
  user_id: number;
  name: string;
  total_payout: number;
}

const Leaderboard: React.FC = () => {
  const [leaderboard, setLeaderboard] = useState<LeaderboardEntry[]>([]);

  const { user } = useContext(AuthContext);

  useEffect(() => {
    // Fetch the initial leaderboard data from the Rails server
    fetch('http://localhost:3000/leaderboard', {
        method: 'GET',
        headers: {
          'Authorization': `Bearer ${user?.token}`,
          'Content-Type': 'application/json',
        },
      })
      .then((response) => response.json())
      .then((data) => {
       
        setLeaderboard(data);
      })
      .catch((error) => {
        console.error('Error fetching leaderboard:', error);
      });

    // Create a new WebSocket connection
    const ws = new WebSocket('ws://localhost:8080');

    // Listen for incoming messages
    ws.onmessage = (event) => {
      try {
        const { type, payload } = JSON.parse(event.data);
        if (type === 'LEADERBOARD_UPDATE') {
          setLeaderboard(payload);
        }
      } catch (error) {
        console.error('Error parsing WebSocket message:', error);
      }
    };

    // Clean up the WebSocket connection when the component unmounts
    // return () => {
    //   ws.close();
    // };
  }, []);

  return (
    <div className="p-6">
      <h1 className="text-2xl font-bold mb-4">Leaderboard</h1>
      {leaderboard.length === 0 ? (
        <p>No leaderboard data yet.</p>
      ) : (
        <table className="min-w-full bg-white shadow-md">
          <thead>
            <tr className="border-b">
              <th className="py-2 px-4 text-left">User</th>
              <th className="py-2 px-4 text-left">Total Payout</th>
            </tr>
          </thead>
          <tbody>
            {leaderboard.map((entry) => (
              <tr key={entry.user_id} className="border-b">
                <td className="py-2 px-4">{entry.name}</td>
                <td className="py-2 px-4">${entry.total_payout}</td>
              </tr>
            ))}
          </tbody>
        </table>
      )}
    </div>
  );
};

export default Leaderboard;
