FactoryBot.define do
  factory :admin do
    full_name{Faker::Name.name}
    email{Faker::Internet.email}
    password "password"
    password_confirmation "password"
  end
end
