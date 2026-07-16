FactoryBot.define do
  factory :recommend_list do
    association :user
    title       { Faker::Lorem.sentence(word_count: 3) }
    description { Faker::Lorem.paragraph }
    status      { :draft }

    trait :published do
      status { :published }
    end
  end
end
