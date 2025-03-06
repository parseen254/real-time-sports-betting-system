require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:email) }
    it { should validate_presence_of(:username) }
    it { should validate_uniqueness_of(:email).case_insensitive }
    it { should validate_uniqueness_of(:username) }
    it { should validate_numericality_of(:balance).is_greater_than_or_equal_to(0) }
  end

  describe 'associations' do
    it { should have_many(:bets).dependent(:destroy) }
  end

  describe 'defaults' do
    it 'sets default balance for new users' do
      user = create(:user)
      expect(user.balance).to eq(1000.0)
    end
  end

  describe '#update_balance!' do
    let(:user) { create(:user, balance: 1000) }

    context 'when adding funds' do
      it 'increases balance' do
        expect { user.update_balance!(500) }
          .to change { user.balance }.from(1000).to(1500)
      end
    end

    context 'when deducting funds' do
      context 'with sufficient balance' do
        it 'decreases balance' do
          expect { user.update_balance!(-500) }
            .to change { user.balance }.from(1000).to(500)
        end
      end

      context 'with insufficient balance' do
        it 'raises InsufficientBalanceError' do
          expect { user.update_balance!(-1500) }
            .to raise_error(User::InsufficientBalanceError)
        end
      end
    end

    context 'with nil amount' do
      it 'raises ArgumentError' do
        expect { user.update_balance!(nil) }
          .to raise_error(ArgumentError)
      end
    end
  end

  describe 'betting statistics' do
    let(:user) { create(:user) }
    let!(:won_bet1) { create(:bet, user: user, amount: 100, odds: 2.0, status: :won) }
    let!(:won_bet2) { create(:bet, user: user, amount: 200, odds: 1.5, status: :won) }
    let!(:lost_bet) { create(:bet, user: user, amount: 150, odds: 2.0, status: :lost) }
    let!(:pending_bet) { create(:bet, user: user, amount: 100, odds: 1.8, status: :pending) }

    describe '#total_winnings' do
      it 'calculates total winnings correctly' do
        # won_bet1: 100 * 2.0 = 200
        # won_bet2: 200 * 1.5 = 300
        # Total: 500
        expect(user.total_winnings).to eq(500.0)
      end
    end

    describe '#total_bets' do
      it 'counts all bets regardless of status' do
        expect(user.total_bets).to eq(4)
      end
    end

    describe '#win_rate' do
      it 'calculates win percentage correctly' do
        # 2 won bets out of 3 completed bets (excluding pending)
        # (2/3) * 100 = 66.67%
        expect(user.win_rate).to eq(66.67)
      end

      context 'with no bets' do
        let(:new_user) { create(:user) }

        it 'returns 0' do
          expect(new_user.win_rate).to eq(0)
        end
      end
    end

    describe '#leaderboard_stats' do
      it 'returns complete stats hash' do
        stats = user.leaderboard_stats
        
        expect(stats).to include(
          id: user.id,
          username: user.username,
          total_winnings: 500.0,
          total_bets: 4,
          win_rate: 66.67
        )
      end
    end
  end
end
