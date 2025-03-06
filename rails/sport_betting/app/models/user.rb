class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :trackable

  has_many :bets, dependent: :destroy
  
  validates :email, presence: true, uniqueness: true
  validates :password, presence: true, length: { minimum: 6 }, if: :password_required?
  validates :username, presence: true, uniqueness: true
  validates :balance, numericality: { greater_than_or_equal_to: 0 }

  after_initialize :set_default_balance, if: :new_record?

  def update_balance!(amount)
    raise ArgumentError, "Amount cannot be nil" if amount.nil?
    
    with_lock do
      new_balance = balance + amount
      if new_balance < 0
        raise InsufficientBalanceError, "Insufficient balance for transaction"
      end
      update!(balance: new_balance)
    end
  end

  def total_winnings
    bets.won.sum('amount * odds')
  end

  def total_bets
    bets.count
  end

  def win_rate
    return 0 if total_bets.zero?
    (bets.won.count.to_f / total_bets * 100).round(2)
  end

  def leaderboard_stats
    {
      id: id,
      username: username,
      total_winnings: total_winnings,
      total_bets: total_bets,
      win_rate: win_rate
    }
  end

  private

  def set_default_balance
    self.balance ||= 1000.0 # Start with 1000 credits
  end

  class InsufficientBalanceError < StandardError; end
end
