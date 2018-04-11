FactoryBot.define do
  factory :rule do
    name{Faker::Name.name}
    organization_id organization
  end
end
