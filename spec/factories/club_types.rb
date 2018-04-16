FactoryBot.define do
  factory :club_type do
    name{Faker::Name.name}
    organization_id organization
  end
end
