class Game < ApplicationRecord
  has_many :bets, dependent: :destroy
  
  validates :name, presence: true
  validates :home_team, presence: true
  validates :away_team, presence: true
  validates :odds_home, presence: true, numericality: { greater_than: 0 }
  validates :odds_away, presence: true, numericality: { greater_than: 0 }
  validates :start_time, presence: true
  
  enum status: {
    scheduled: 0,
    in_progress: 1,
    completed: 2,
    cancelled: 3
  }

  def update_odds(data)
    transaction do
      parsed_data = JSON.parse(data)
      self.odds_home = parsed_data['odds_home']
      self.odds_away = parsed_data['odds_away']
      save!
      
      # Publish updates to Redis for real-time notifications
      REDIS.publish('game_updates', {
        game_id: id,
        odds_home: odds_home,
        odds_away: odds_away,
        status: status
      }.to_json)
    end
  end

  def start_game!
    return false if !scheduled?
    update!(status: :in_progress)
  end

  def complete_game!(winner)
    return false if !in_progress?
    
    transaction do
      update!(status: :completed)
      process_bets(winner)
    end
  end

  private

  def process_bets(winner)
    bets.each do |bet|
      bet.process_result(winner)
    end
  end
end
