FactoryBot.define do
  factory :user_club do
    user_id user
    club_id club
    status :joined
  end
end
