class Bet < ApplicationRecord
  belongs_to :user
  belongs_to :game

  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :odds, presence: true, numericality: { greater_than: 0 }
  validates :selected_team, presence: true
  validate :user_has_sufficient_balance, on: :create
  validate :game_is_scheduled, on: :create

  enum status: {
    pending: 0,
    won: 1,
    lost: 2,
    cancelled: 3
  }

  before_create :deduct_user_balance
  after_save :update_leaderboard, if: :status_changed?

  def process_result(winner)
    return if !pending?

    transaction do
      if winner == selected_team
        win_amount = calculate_win_amount
        user.update!(balance: user.balance + win_amount)
        update!(status: :won)
      else
        update!(status: :lost)
      end
    end
  end

  private

  def calculate_win_amount
    amount * odds
  end

  def user_has_sufficient_balance
    return unless user && amount
    if user.balance < amount
      errors.add(:amount, "insufficient balance")
    end
  end

  def game_is_scheduled
    return unless game
    if !game.scheduled?
      errors.add(:game, "must be in scheduled state")
    end
  end

  def deduct_user_balance
    user.update!(balance: user.balance - amount)
  end

  def update_leaderboard
    return unless won?
    
    REDIS.publish('leaderboard_updates', {
      user_id: user_id,
      win_amount: calculate_win_amount,
      timestamp: Time.current
    }.to_json)
  end
end
