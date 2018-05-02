class UserEvent < ApplicationRecord
  belongs_to :user, ->{with_deleted}
  belongs_to :event

  has_many :activities, as: :trackable, dependent: :destroy

  scope :by_user, ->user_id{where user_id: user_id}
  scope :by_events, ->event_ids{where event_id: event_ids}

  delegate :full_name, :avatar, to: :user, prefix: :user
end
