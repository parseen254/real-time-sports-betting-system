class Game < ApplicationRecord
  has_many :bets
  def update_odds(data)
    parsed_data = JSON.parse(data)
    self.odds = parsed_data['oddsA']
    save!
  end
end
