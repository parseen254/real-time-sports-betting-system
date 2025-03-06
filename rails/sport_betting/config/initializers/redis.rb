require 'redis'

redis_url = ENV.fetch('REDIS_URL', 'redis://localhost:6379/0')

Redis.current = Redis.new(url: redis_url)

# Configure connection pool for concurrent access
REDIS_POOL = ConnectionPool.new(size: 5, timeout: 5) do
  Redis.new(url: redis_url)
end

# Helper method to execute Redis commands within a connection pool block
def with_redis(&block)
  REDIS_POOL.with(&block)
end

# Configure Redis for caching if enabled
if Rails.application.config.cache_store.first == :redis_cache_store
  Rails.application.config.cache_store = [:redis_cache_store, { url: redis_url }]
end

# Health check method
def redis_connected?
  Redis.current.ping == 'PONG'
rescue Redis::CannotConnectError
  false
end

# Subscribe to channels in development
if Rails.env.development?
  Thread.new do
    begin
      Redis.current.subscribe('game_updates', 'leaderboard_updates') do |on|
        on.message do |channel, msg|
          Rails.logger.debug "Redis: #{channel} - #{msg}"
        end
      end
    rescue Redis::BaseConnectionError => e
      Rails.logger.error "Redis subscription error: #{e.message}"
    end
  end
end
