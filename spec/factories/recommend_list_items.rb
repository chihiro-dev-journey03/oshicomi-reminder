FactoryBot.define do
  factory :recommend_list_item do
    association :recommend_list
    association :book
    comment { Faker::Lorem.sentence }
  end
end
