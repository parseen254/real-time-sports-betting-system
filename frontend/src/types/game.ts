export interface Game {
    id: string;
    game_id: string;
    home_team: string;
    away_team: string;
    score: string;
    status: string;
    minute: number;
    odds: {
      home_win: number;
      draw: number;
      away_win: number;
    }|null;
}
