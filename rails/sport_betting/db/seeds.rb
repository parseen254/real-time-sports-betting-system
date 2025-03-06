puts "Starting database seeding..."

# Create admin user
admin = User.create!(
  email: 'admin@example.com',
  username: 'admin',
  password: 'admin123',
  password_confirmation: 'admin123',
  balance: 10000.0
)
puts "Created admin user: #{admin.email}"

# Create some initial games
5.times do |i|
  game = Game.create!(
    name: "Opening Game #{i + 1}",
    home_team: "Home Team #{i + 1}",
    away_team: "Away Team #{i + 1}",
    odds_home: 1.8 + (rand * 0.5),
    odds_away: 1.8 + (rand * 0.5),
    start_time: Time.current + (i + 1).hours,
    status: :scheduled
  )
  puts "Created game: #{game.name}"
end

# Create a demo user with some bets
demo_user = User.create!(
  email: 'demo@example.com',
  username: 'demo',
  password: 'demo123',
  password_confirmation: 'demo123',
  balance: 5000.0
)
puts "Created demo user: #{demo_user.email}"

# Create some initial bets for demo user
Game.all.each do |game|
  selected_team = [game.home_team, game.away_team].sample
  odds = selected_team == game.home_team ? game.odds_home : game.odds_away
  
  Bet.create!(
    user: demo_user,
    game: game,
    amount: 100.0,
    odds: odds,
    selected_team: selected_team,
    status: :pending
  )
  puts "Created bet for game #{game.name} by demo user"
end

puts "\nSeeding completed successfully!"
puts "Created:"
puts "  - #{User.count} users"
puts "  - #{Game.count} games"
puts "  - #{Bet.count} bets"
puts "\nYou can log in with:"
puts "Admin - email: admin@example.com, password: admin123"
puts "Demo - email: demo@example.com, password: demo123"
