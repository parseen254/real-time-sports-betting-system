module Api::V1
  class BetsController < ApplicationController
    before_action :authenticate_user!
    before_action :set_game, only: [:create]

    def create
      @bet = current_user.bets.build(bet_params.merge(game: @game))

      ActiveRecord::Base.transaction do
        if @bet.save
          fraud_analysis = FraudDetectionService.analyze_betting_patterns(current_user)
          
          if fraud_analysis[:fraud]
            raise FraudSuspicionError, fraud_analysis[:message]
          end

          render json: {
            bet: @bet.as_json(include: :game),
            user_balance: current_user.balance
          }, status: :created
        else
          render json: { errors: @bet.errors.full_messages }, status: :unprocessable_entity
        end
      end
    rescue User::InsufficientBalanceError => e
      render json: { error: e.message }, status: :payment_required
    rescue FraudSuspicionError => e
      @bet.destroy
      render json: { error: e.message }, status: :forbidden
    rescue => e
      render json: { error: "An unexpected error occurred" }, status: :internal_server_error
    end

    def index
      @bets = current_user.bets.includes(:game)
                         .order(created_at: :desc)
                         .page(params[:page])
                         .per(20)

      render json: {
        bets: @bets.as_json(include: :game),
        meta: {
          total_pages: @bets.total_pages,
          current_page: @bets.current_page,
          total_count: @bets.total_count
        }
      }
    end

    def show
      @bet = current_user.bets.includes(:game).find(params[:id])
      render json: @bet.as_json(include: :game)
    rescue ActiveRecord::RecordNotFound
      render json: { error: "Bet not found" }, status: :not_found
    end

    private

    def bet_params
      params.require(:bet).permit(:amount, :odds, :selected_team)
    end

    def set_game
      @game = Game.find(params[:game_id])
    rescue ActiveRecord::RecordNotFound
      render json: { error: "Game not found" }, status: :not_found
    end

    class FraudSuspicionError < StandardError; end
  end
end
