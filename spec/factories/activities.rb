FactoryBot.define do
  factory :activity do
    container_id{|a| a.association(:club)}
    owner_id{|a| a.association(:user)}
    trackable_id{|a| a.association(:club)}
  end
end
