module Api::V1
  class BetsController < ApplicationController
    before_action :authenticate_user!
    before_action :set_game, only: [:create]

    def create
      @bet = current_user.bets.build(bet_params)

      if @bet.save
        render json: {
          bet: @bet.as_json(include: :game),
          user_balance: current_user.balance
        }, status: :created
      else
        render json: { errors: @bet.errors.full_messages }, status: :unprocessable_entity
      end
    rescue User::InsufficientBalanceError => e
      render json: { error: e.message }, status: :payment_required
    rescue => e
      render json: { error: "An unexpected error occurred" }, status: :internal_server_error
      User.transaction do
        user = User.find(params[:user_id])
        amount = bet_params[:amount].to_d
        raise ActiveRecord::Rollback unless user.balance >= amount
        user.update_column(:balance, user.balance - amount)
        bet = user.bets.create!(bet_params)
        fraud_analysis = FraudDetectionService.analyze_betting_patterns(user)
        if fraud_analysis[:fraud]
          puts "Fraud detected for user #{user.id}: #{fraud_analysis[:message]}"
        end
        render json: bet, status: :created
      end
    rescue ActiveRecord::Rollback
      render json: { error: 'Insufficient balance' }, status: :unprocessable_entity
    end

    private
    def bet_params
      params.require(:bet).permit(:game_id, :amount, :odds, :status)
    end
  end
end
