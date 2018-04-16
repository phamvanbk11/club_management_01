FactoryBot.define do
  factory :club do
    name{Faker::Name.name}
    content{Faker::Internet.email}
    goal{Faker::PhoneNumber.phone_number}
    organization_id organization
  end
end
