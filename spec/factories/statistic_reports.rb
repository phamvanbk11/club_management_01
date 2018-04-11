FactoryBot.define do
  factory :statistic_report do
    user_id user
    style 2
    club_id club
    plan_next_month{Faker::Lorem.sentence}
    time 2
    status 2
    year 2018
  end
end
