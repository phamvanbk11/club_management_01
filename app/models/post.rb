class Post < ApplicationRecord
  acts_as_paranoid

  belongs_to :user, ->{with_deleted}
  belongs_to :target, polymorphic: true
  has_many :post_galleries, dependent: :destroy

  validates :name, presence: true
  validates :content, presence: true

  scope :newest, ->{order created_at: :desc}

  accepts_nested_attributes_for :post_galleries, allow_destroy: true,
    reject_if: proc {|attributes| attributes[:url].blank? && attributes[:url_video].blank?}

  delegate :full_name, :avatar, to: :user, prefix: :user
end
