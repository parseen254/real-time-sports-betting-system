FactoryBot.define do
  factory :bet do
    amount { 100 }
    odds { 1.5 }
    status { 1 } # 1 = pending, 2 = won, 3 = lost
    user
    game { create(:game, odds: 1.5) }

    trait :won do
      status { 2 }
    end

    trait :lost do
      status { 3 }
    end
  end
end
