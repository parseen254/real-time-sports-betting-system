require 'rails_helper'

RSpec.describe Bet, type: :model do
  let(:user) { create(:user) }
  let(:game) { create(:game) }
  
  describe 'validations' do
    it { should validate_presence_of(:amount) }
    it { should validate_presence_of(:odds) }
    it { should validate_presence_of(:selected_team) }
    
    it { should validate_numericality_of(:amount).is_greater_than(0) }
    it { should validate_numericality_of(:odds).is_greater_than(0) }
  end

  describe 'associations' do
    it { should belong_to(:user) }
    it { should belong_to(:game) }
  end

  describe '#process_result' do
    let(:bet) { create(:bet, user: user, game: game, amount: 100, odds: 2.0, selected_team: 'Team A') }

    context 'when the bet wins' do
      it 'updates the user balance and marks bet as won' do
        initial_balance = user.balance
        bet.process_result('Team A')
        
        expect(bet.won?).to be true
        expect(user.reload.balance).to eq(initial_balance + 200) # 100 * 2.0
      end
    end

    context 'when the bet loses' do
      it 'marks bet as lost and does not update balance' do
        initial_balance = user.balance - 100 # because bet amount is already deducted
        bet.process_result('Team B')
        
        expect(bet.lost?).to be true
        expect(user.reload.balance).to eq(initial_balance)
      end
    end
  end

  describe 'balance validation' do
    context 'when user has insufficient balance' do
      it 'prevents bet creation' do
        user.update!(balance: 50)
        bet = build(:bet, user: user, amount: 100)
        
        expect(bet.valid?).to be false
        expect(bet.errors[:amount]).to include('insufficient balance')
      end
    end
  end

  describe 'game state validation' do
    context 'when game is not scheduled' do
      it 'prevents bet creation' do
        game.update!(status: :in_progress)
        bet = build(:bet, user: user, game: game)
        
        expect(bet.valid?).to be false
        expect(bet.errors[:game]).to include('must be in scheduled state')
      end
    end
  end

  describe 'callbacks' do
    it 'deducts bet amount from user balance on creation' do
      initial_balance = user.balance
      bet = create(:bet, user: user, amount: 100)
      
      expect(user.reload.balance).to eq(initial_balance - 100)
    end
  end
end
