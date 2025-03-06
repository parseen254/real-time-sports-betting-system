require 'rails_helper'

RSpec.describe FraudDetectionService do
  let(:user) { create(:user) }
  let(:service) { FraudDetectionService.new(user) }

  describe '#analyze' do
    context 'with no suspicious patterns' do
      it 'returns no fraud detected' do
        result = service.analyze
        
        expect(result[:fraud]).to be false
        expect(result[:message]).to eq("No suspicious patterns detected")
        expect(result[:severity]).to eq(:low)
      end
    end

    context 'with high betting frequency' do
      before do
        21.times do
          create(:bet, user: user, created_at: 30.minutes.ago)
        end
      end

      it 'detects suspicious betting frequency' do
        result = service.analyze
        
        expect(result[:fraud]).to be true
        expect(result[:message]).to include("Unusual betting frequency detected")
        expect(result[:severity]).to eq(:low)
      end
    end

    context 'with large betting amounts' do
      before do
        create(:bet, user: user, amount: 11000, created_at: 30.minutes.ago)
      end

      it 'detects suspicious betting amounts' do
        result = service.analyze
        
        expect(result[:fraud]).to be true
        expect(result[:message]).to include("Large betting volume detected")
        expect(result[:severity]).to eq(:low)
      end
    end

    context 'with unusually high win rate' do
      before do
        15.times do
          create(:bet, user: user, status: :won)
        end
      end

      it 'detects suspicious win rate' do
        result = service.analyze
        
        expect(result[:fraud]).to be true
        expect(result[:message]).to include("Unusually high win rate")
        expect(result[:severity]).to eq(:low)
      end
    end

    context 'with unusual odds' do
      before do
        create(:bet, user: user, odds: 12.0, created_at: 30.minutes.ago)
      end

      it 'detects suspicious odds' do
        result = service.analyze
        
        expect(result[:fraud]).to be true
        expect(result[:message]).to include("Bets placed with unusually high odds")
        expect(result[:severity]).to eq(:low)
      end
    end

    context 'with multiple suspicious patterns' do
      before do
        create(:bet, user: user, odds: 12.0, amount: 11000, created_at: 30.minutes.ago)
        20.times do
          create(:bet, user: user, status: :won, created_at: 30.minutes.ago)
        end
      end

      it 'detects multiple patterns with high severity' do
        result = service.analyze
        
        expect(result[:fraud]).to be true
        expect(result[:severity]).to eq(:high)
        expect(result[:message]).to include("Unusual betting frequency")
        expect(result[:message]).to include("Large betting volume")
        expect(result[:message]).to include("high win rate")
        expect(result[:message]).to include("unusually high odds")
      end
    end
  end

  describe 'logging' do
    let(:logger) { double('Logger') }
    
    before do
      stub_const('Rails', double(logger: logger))
      create(:bet, user: user, odds: 12.0, created_at: 30.minutes.ago)
    end

    it 'logs suspicious activity' do
      expect(logger).to receive(:warn).with(/Suspicious betting activity detected/)
      service.analyze
    end
  end
end
