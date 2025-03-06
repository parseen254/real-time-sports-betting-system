FactoryBot.define do
  factory :bet do
    association :user
    association :game
    amount { 100.0 }
    odds { 2.0 }
    selected_team { game.home_team }
    status { :pending }

    trait :won do
      status { :won }
      after(:create) do |bet|
        bet.game.update!(status: :completed, winner: bet.selected_team)
      end
    end

    trait :lost do
      status { :lost }
      after(:create) do |bet|
        bet.game.update!(status: :completed, winner: bet.selected_team == bet.game.home_team ? bet.game.away_team : bet.game.home_team)
      end
    end

    trait :cancelled do
      status { :cancelled }
      after(:create) do |bet|
        bet.game.update!(status: :cancelled)
      end
    end

    trait :high_stakes do
      amount { 1000.0 }
      odds { 5.0 }
    end

    trait :minimal_bet do
      amount { 10.0 }
      odds { 1.2 }
    end

    # For testing fraud detection
    trait :suspicious do
      amount { 11000.0 }
      odds { 12.0 }
    end
  end
end
