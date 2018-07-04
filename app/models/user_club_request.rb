class UserClubRequest < ApplicationRecord
  belongs_to :user
  belongs_to :club_request

  scope :user_club_requests, ->(request_id){where club_request_id: request_id}
  scope :by_user, ->(user_id){where user_id: user_id}
end
