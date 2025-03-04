require 'rails_helper'
RSpec.describe Api::V1::UsersController, type: :controller do
  describe 'POST #create' do
    it 'creates a new user' do
      post :create, params: { user: { email: 'test@example.com', password: 'password' } }
      expect(response).to have_http_status(:created)
    end
  end
end