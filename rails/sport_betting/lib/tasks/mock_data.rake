namespace :mock_data do
  desc "Generate mock data for development and testing"
  task generate: :environment do
    puts "Generating mock data..."

    ActiveRecord::Base.transaction do
      # Create users
      10.times do |i|
        User.create!(
          email: "user#{i}@example.com",
          username: "user#{i}",
          password: "password123",
          password_confirmation: "password123",
          balance: 1000.0 + (rand * 9000)
        )
      end

      # Create games
      20.times do |i|
        start_time = Time.current + rand(1..48).hours
        game = Game.create!(
          name: "Game #{i}",
          home_team: "Team #{i*2}",
          away_team: "Team #{i*2 + 1}",
          odds_home: 1.5 + (rand * 2),
          odds_away: 1.5 + (rand * 2),
          start_time: start_time,
          status: [:scheduled, :in_progress, :completed].sample
        )

        # Create some bets for this game
        User.all.sample(3).each do |user|
          selected_team = [game.home_team, game.away_team].sample
          odds = selected_team == game.home_team ? game.odds_home : game.odds_away
          amount = 10.0 + (rand * 90)

          begin
            Bet.create!(
              user: user,
              game: game,
              amount: amount,
              odds: odds,
              selected_team: selected_team,
              status: game.completed? ? [:won, :lost].sample : :pending
            )
          rescue => e
            puts "Failed to create bet: #{e.message}"
          end
        end
      end
    end

    puts "Mock data generated successfully!"
    puts "Created:"
    puts "  - #{User.count} users"
    puts "  - #{Game.count} games"
    puts "  - #{Bet.count} bets"
  end

  desc "Simulate real-time changes in the system"
  task simulate_changes: :environment do
    puts "Starting simulation of real-time changes..."
    
    10.times do |i|
      puts "\nSimulation round #{i + 1}"
      
      # Update random game odds
      Game.where(status: [:scheduled, :in_progress]).sample(2).each do |game|
        old_home = game.odds_home
        old_away = game.odds_away
        
        game.update_odds({
          odds_home: (old_home * (0.8 + (rand * 0.4))).round(2),
          odds_away: (old_away * (0.8 + (rand * 0.4))).round(2)
        }.to_json)
        
        puts "Updated odds for #{game.name}"
      end

      # Start some scheduled games
      Game.scheduled.sample(1).each do |game|
        game.start_game!
        puts "Started #{game.name}"
      end

      # Complete some in-progress games
      Game.in_progress.sample(1).each do |game|
        winner = [game.home_team, game.away_team].sample
        game.complete_game!(winner)
        puts "Completed #{game.name}, winner: #{winner}"
      end

      # Create some new bets
      3.times do
        user = User.all.sample
        game = Game.scheduled.sample
        
        next unless game && user

        amount = 10.0 + (rand * 90)
        selected_team = [game.home_team, game.away_team].sample
        odds = selected_team == game.home_team ? game.odds_home : game.odds_away

        begin
          bet = Bet.create!(
            user: user,
            game: game,
            amount: amount,
            odds: odds,
            selected_team: selected_team
          )
          puts "New bet placed by #{user.username} on #{game.name}"
        rescue => e
          puts "Failed to create bet: #{e.message}"
        end
      end

      sleep 2 # Pause between simulation rounds
    end

    puts "\nSimulation completed!"
  end
end
