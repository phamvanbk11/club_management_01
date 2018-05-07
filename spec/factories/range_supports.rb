FactoryBot.define do
  factory :range_support do
    operator 0
    value_from 30
    value_to 50
    style 1
    organization_id organization
  end
end
