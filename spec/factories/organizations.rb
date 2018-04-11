FactoryBot.define do
  factory :organization do
    name{Faker::Name.name}
    email{Faker::Internet.email}
    phone{Faker::PhoneNumber.phone_number}
    location{Faker::Address.city}
    description{Faker::Lorem.sentence}
    logo{Faker::Lorem.sentence}
  end
end
