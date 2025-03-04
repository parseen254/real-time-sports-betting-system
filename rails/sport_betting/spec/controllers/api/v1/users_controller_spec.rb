require 'rails_helper'
RSpec.describe Api::V1::UsersController, type: :controller do
  describe 'POST #create' do
    it 'creates a new user' do
      post :create, params: { user: { email: 'test@example.com', password: 'password' } }
      expect(response).to have_http_status(:created)
    end
  end

  describe 'GET #bets' do
    let(:user) { create(:user) }
    let!(:bet1) { create(:bet, user: user) }
    let!(:bet2) { create(:bet, user: user) }

    it 'returns user bets' do
      get :bets, params: { id: user.id }
      expect(response).to have_http_status(:ok)
      json_response = JSON.parse(response.body)
      expect(json_response.size).to eq(2)
    end
  end
end
