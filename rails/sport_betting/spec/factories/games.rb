FactoryBot.define do
  factory :game do
    name { "Game #{rand(1000)}" }
    odds { rand(1.0..10.0).round(2) }
  end
end
