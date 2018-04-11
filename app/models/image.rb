class Image < ApplicationRecord
  belongs_to :album
  belongs_to :user, ->{with_deleted}

  has_many :activities, as: :trackable, dependent: :destroy

  mount_uploader :url, ImageUploader

  scope :newest, ->{order created_at: :desc}
end
