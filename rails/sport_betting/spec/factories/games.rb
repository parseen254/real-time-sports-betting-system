FactoryBot.define do
  factory :game do
    sequence(:name) { |n| "Game #{n}" }
    home_team { "Team A" }
    away_team { "Team B" }
    odds_home { 1.8 }
    odds_away { 2.0 }
    start_time { 1.day.from_now }
    status { :scheduled }

    trait :in_progress do
      status { :in_progress }
    end

    trait :completed do
      status { :completed }
      winner { home_team }
    end

    trait :cancelled do
      status { :cancelled }
    end

    trait :with_high_odds do
      odds_home { 5.0 }
      odds_away { 7.0 }
    end

    trait :starting_soon do
      start_time { 1.hour.from_now }
    end
  end
end
