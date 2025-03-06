namespace :mock do
  desc "Publish a mock game data event to Redis"
  task :game_data do
    require 'redis'
    # Get the Redis URL from environment variables or default to localhost.
    redis_url = ENV['REDIS_URL'] || 'redis://localhost:6379/0'
    redis = Redis.new(url: redis_url)

    # Create a sample game event payload.
    event_payload = {
      game_id: "G1234",
      home_team: "Lions",
      away_team: "Tigers",
      score: "1-0",
      status: "in_progress",
      minute: 23,
      event: "goal",
      event_team: "Lions",
      message: "Lions scored a goal!",
      timestamp: Time.now.iso8601,
      odds: {
        home_win: 1.75,
        draw: 3.2,
        away_win: 4.5
      }
    }
    
    # Publish the payload on the 'game_updates' Redis channel.
    redis.publish('game_updates', event_payload.to_json)
    puts "Mock game data published: #{event_payload}"
  end
end

namespace :fraud do
  desc "Check for potential fraud in betting patterns"
  task :check => :environment do
    # Iterate over all users and check betting patterns using FraudDetectionService.
    User.find_each do |user|
      message = FraudDetectionService.flag(user)
      puts "User #{user.email}: #{message}" if message
    end
    puts "Fraud check completed."
  end
end
