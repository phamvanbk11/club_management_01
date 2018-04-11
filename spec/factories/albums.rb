FactoryBot.define do
  factory :album do
    name{Faker::Name.name}
    club_id club
  end
end
