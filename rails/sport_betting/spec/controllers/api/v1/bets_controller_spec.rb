require 'rails_helper'

RSpec.describe Api::V1::BetsController, type: :controller do
  let(:user) { create(:user) }
  let(:game) { create(:game) }
  
  before do
    sign_in user
  end

  describe 'POST #create' do
    let(:valid_params) do
      {
        game_id: game.id,
        bet: {
          amount: 100,
          odds: 2.0,
          selected_team: game.home_team
        }
      }
    end

    context 'with valid parameters' do
      it 'creates a new bet' do
        expect {
          post :create, params: valid_params
        }.to change(Bet, :count).by(1)

        expect(response).to have_http_status(:created)
        expect(JSON.parse(response.body)).to include(
          'bet',
          'user_balance'
        )
      end

      it 'deducts the bet amount from user balance' do
        initial_balance = user.balance
        post :create, params: valid_params
        
        expect(user.reload.balance).to eq(initial_balance - 100)
      end
    end

    context 'with insufficient balance' do
      before { user.update!(balance: 50) }

      it 'returns payment required status' do
        post :create, params: valid_params
        
        expect(response).to have_http_status(:payment_required)
        expect(JSON.parse(response.body)['error']).to include('insufficient balance')
      end
    end

    context 'with invalid game' do
      it 'returns not found status' do
        post :create, params: valid_params.merge(game_id: 0)
        
        expect(response).to have_http_status(:not_found)
        expect(JSON.parse(response.body)['error']).to eq('Game not found')
      end
    end

    context 'when fraud is detected' do
      let(:suspicious_params) do
        {
          game_id: game.id,
          bet: {
            amount: 11000,
            odds: 12.0,
            selected_team: game.home_team
          }
        }
      end

      it 'prevents bet creation and returns forbidden status' do
        post :create, params: suspicious_params
        
        expect(response).to have_http_status(:forbidden)
        expect(JSON.parse(response.body)['error']).to include('suspicious')
      end
    end
  end

  describe 'GET #index' do
    before do
      create_list(:bet, 3, user: user)
      create(:bet) # another user's bet
    end

    it 'returns user bets with pagination' do
      get :index
      
      expect(response).to have_http_status(:ok)
      json_response = JSON.parse(response.body)
      
      expect(json_response['bets'].length).to eq(3)
      expect(json_response['meta']).to include(
        'total_pages',
        'current_page',
        'total_count'
      )
    end

    it 'includes game information' do
      get :index
      
      bet = JSON.parse(response.body)['bets'].first
      expect(bet).to include('game')
    end
  end

  describe 'GET #show' do
    let(:bet) { create(:bet, user: user) }

    it 'returns the requested bet' do
      get :show, params: { id: bet.id }
      
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)).to include(
        'id' => bet.id,
        'amount' => bet.amount.as_json,
        'status' => bet.status
      )
    end

    context 'with another user\'s bet' do
      let(:other_bet) { create(:bet) }

      it 'returns not found status' do
        get :show, params: { id: other_bet.id }
        
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
