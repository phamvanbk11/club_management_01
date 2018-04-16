FactoryBot.define do
  factory :organization_setting do
    key Settings.key_date_remind_month
    organization_id organization
    value 1
  end
end
