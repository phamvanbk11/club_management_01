FactoryBot.define do
  factory :post do
    name{Faker::Name.name}
    content{Faker::Name.name}
  end
end
