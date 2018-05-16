FactoryBot.define do
  factory :sponsor do
    purpose{Faker::Name.name}
    time Time.now
    place{Faker::Address.city}
    communication_plan{Faker::Name.name}
    organizational_units{Faker::Name.name}
    participating_units{Faker::Name.name}
    sponsor 10000
    club_id club
    user_id user
  end
end
