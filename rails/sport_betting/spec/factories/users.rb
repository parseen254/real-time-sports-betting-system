FactoryBot.define do
  factory :user do
    email { "user#{rand(1..1000)}@example.com" }
    password { "password" }
    password_confirmation { "password" }
    balance { 1000.00 }
  end
end
