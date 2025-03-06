namespace :db do
  desc "Generate mock game data"
  task :mock_games => :environment do
    puts "Generating mock games..."
    10.times do |i|
      Game.create!(
        name: "Game #{i+1}",
        odds: rand(1.0..5.0).round(2)
      )
    end
    puts "Mock games generated!"
  end
end
