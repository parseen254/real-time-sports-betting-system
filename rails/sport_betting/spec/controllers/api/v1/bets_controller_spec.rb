require 'rails_helper'
RSpec.describe Api::V1::BetsController, type: :controller do
  describe 'POST #create' do
    it 'creates a new bet' do
      user = FactoryBot.create(:user)
      game = FactoryBot.create(:game)
      post :create, params: { user_id: user.id, bet: { game_id: game.id, amount: 100, odds: 200, status: 0 } }
      expect(response).to have_http_status(:created)
    end
  end
end
