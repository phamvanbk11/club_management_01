FactoryBot.define do
  factory :event do
    name{Faker::Name.name}
    location{Faker::Name.name}
    date_start 5.day.ago
    date_end Date.today
    club_id club
    user_id user
    event_category :activity_money
  end
end
