class ClubRequest < ApplicationRecord
  belongs_to :organization
  belongs_to :user
  has_many :activities, as: :target, dependent: :destroy

  enum approve: {approved: true, un_approve: false}

  scope :order_date_desc, -> {order created_at: :desc}

  mount_uploader :logo, ImageUploader
end
