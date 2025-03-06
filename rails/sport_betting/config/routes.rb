Rails.application.routes.draw do
  # Health check endpoint
  get '/health', to: 'health#show'

  # Devise routes for authentication
  devise_for :users, controllers: {
    sessions: 'users/sessions',
    registrations: 'users/registrations'
  }

  # API routes
  namespace :api do
    namespace :v1 do
      resources :users, only: [:create] do
        member do
          get :bets
        end
      end
      resources :bets, only: [:create, :index, :show]
      resources :games, only: [:index, :show]
      get 'leaderboard', to: 'leaderboard#index'
    end
  end

  # WebSocket cable route
  mount ActionCable.server => '/cable'

  # Root route for API documentation
  root 'api_docs#index'
end
