class HealthController < ApplicationController
  def show
    health_status = {
      status: "ok",
      timestamp: Time.current,
      database: database_connected?,
      redis: redis_connected?
    }

    render json: health_status
  end

  private

  def database_connected?
    ActiveRecord::Base.connection.active?
    true
  rescue StandardError
    false
  end

  def redis_connected?
    Redis.current.ping == "PONG"
    true
  rescue StandardError
    false
  end
end
