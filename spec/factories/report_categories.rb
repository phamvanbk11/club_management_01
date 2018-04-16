FactoryBot.define do
  factory :report_category do
    name{Faker::Name.name}
    organization_id organization
  end
end
