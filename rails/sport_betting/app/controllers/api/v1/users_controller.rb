module Api::V1
  class UsersController < ApplicationController
    def create
      user = User.new(user_params)
      if user.save
        render json: user, status: :created
      else
        render json: user.errors, status: :unprocessable_entity
      end
    end

    def bets
      user = User.find_by(id: params[:id])
      bets = user ? user.bets : []
      render json: bets
    end

    private
    def user_params
      params.require(:user).permit(:email, :password)
    end
  end
end
