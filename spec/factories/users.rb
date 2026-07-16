FactoryBot.define do
  factory :user do
    name  { Faker::Name.name }
    email { Faker::Internet.unique.email }
    password { "password123" }
    provider { nil }
    uid      { nil }
  end

  factory :line_user, class: "User" do
    name     { Faker::Name.name }
    provider { "line" }
    uid      { Faker::Number.unique.number(digits: 10).to_s }
    email    { "#{uid}@line.example.com" }
    password { Devise.friendly_token[0, 20] }
  end
end
