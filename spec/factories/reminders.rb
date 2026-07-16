FactoryBot.define do
  factory :reminder do
    association :user
    association :book
    recurrence_type     { "daily" }
    recurrence_interval { 1 }
    time_hour           { 9 }
    time_minute         { 0 }
    status              { :pending }
    days_of_week        { 0 }
    monthly_type        { "date" }
    day_of_month        { 1 }
    week_of_month       { nil }
    weekday             { nil }

    trait :weekly do
      recurrence_type { "weekly" }
      days_of_week    { 0b0000010 } # 月曜日
    end

    trait :monthly_date do
      recurrence_type { "monthly" }
      monthly_type    { "date" }
      day_of_month    { 1 }
    end

    trait :monthly_weekday do
      recurrence_type { "monthly" }
      monthly_type    { "weekday" }
      week_of_month   { 1 }
      weekday         { 1 } # 月曜日
    end
  end
end
