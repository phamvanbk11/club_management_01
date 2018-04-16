FactoryBot.define do
  factory :rule_detail do
    content{Faker::Lorem.sentence}
    points 10
    rule_id rule
  end
end
