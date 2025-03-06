require 'rails_helper'

RSpec.describe Game, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:home_team) }
    it { should validate_presence_of(:away_team) }
    it { should validate_presence_of(:odds_home) }
    it { should validate_presence_of(:odds_away) }
    it { should validate_presence_of(:start_time) }
    
    it { should validate_numericality_of(:odds_home).is_greater_than(0) }
    it { should validate_numericality_of(:odds_away).is_greater_than(0) }
  end

  describe 'associations' do
    it { should have_many(:bets).dependent(:destroy) }
  end

  describe 'enums' do
    it { should define_enum_for(:status).with_values([:scheduled, :in_progress, :completed, :cancelled]) }
  end

  let(:game) { create(:game) }

  describe '#update_odds' do
    let(:new_odds) do
      {
        odds_home: 2.5,
        odds_away: 1.8
      }.to_json
    end

    it 'updates odds and publishes to Redis' do
      redis = double('Redis')
      stub_const('REDIS', redis)
      
      expect(redis).to receive(:publish).with(
        'game_updates',
        {
          game_id: game.id,
          odds_home: 2.5,
          odds_away: 1.8,
          status: game.status
        }.to_json
      )

      game.update_odds(new_odds)
      
      expect(game.odds_home).to eq(2.5)
      expect(game.odds_away).to eq(1.8)
    end
  end

  describe '#start_game!' do
    context 'when game is scheduled' do
      it 'changes status to in_progress' do
        expect { game.start_game! }.to change { game.status }.from('scheduled').to('in_progress')
      end
    end

    context 'when game is not scheduled' do
      before { game.update!(status: :completed) }

      it 'returns false' do
        expect(game.start_game!).to be false
        expect(game.status).to eq('completed')
      end
    end
  end

  describe '#complete_game!' do
    before { game.update!(status: :in_progress) }

    context 'when game is in progress' do
      it 'changes status to completed and processes bets' do
        bet1 = create(:bet, game: game, selected_team: 'Team A')
        bet2 = create(:bet, game: game, selected_team: 'Team B')
        
        expect(bet1).to receive(:process_result).with('Team A')
        expect(bet2).to receive(:process_result).with('Team A')
        
        game.complete_game!('Team A')
        
        expect(game.status).to eq('completed')
      end
    end

    context 'when game is not in progress' do
      before { game.update!(status: :scheduled) }

      it 'returns false' do
        expect(game.complete_game!('Team A')).to be false
        expect(game.status).to eq('scheduled')
      end
    end
  end
end
