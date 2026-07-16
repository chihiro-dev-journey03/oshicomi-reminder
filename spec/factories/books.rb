FactoryBot.define do
  factory :book do
    title     { Faker::Book.title }
    author    { Faker::Book.author }
    image_url { "https://example.com/#{Faker::Number.number(digits: 6)}.jpg" }
  end
end
