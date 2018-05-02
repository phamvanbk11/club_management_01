class Organization < ApplicationRecord
  acts_as_paranoid

  attr_accessor :bgr_crop_x, :bgr_crop_y, :bgr_crop_w, :bgr_crop_h

  extend FriendlyId
  friendly_id :name, use: :slugged

  has_many :clubs, dependent: :destroy
  has_many :users, through: :user_organizations
  has_many :user_organizations, dependent: :destroy
  has_many :club_requests, dependent: :destroy
  has_many :activities, as: :container, dependent: :destroy
  has_many :activities, as: :trackable, dependent: :destroy
  has_many :club_types, dependent: :destroy
  has_many :report_categories, dependent: :destroy
  has_many :events, through: :clubs
  has_many :sponsors, through: :clubs
  has_many :organization_settings, dependent: :destroy
  has_many :rules, dependent: :destroy
  has_many :range_supports, dependent: :destroy
  has_many :money_supports, dependent: :destroy

  validates :name, uniqueness: true, presence: true,
    length: {maximum: Settings.max_name}
  validates :email, uniqueness: true, presence: true
  validates :phone, presence: true
  validates :location, presence: true
  validates :description, presence: true

  enum status: {professed: 0, hide: 1}

  mount_uploader :logo, BackgroundOrganizationUploader

  scope :newest, ->{order created_at: :desc}
  scope :by_user_organizations, ->user_organizations do
    where id: user_organizations.map(&:organization_id)
  end

  CROP_BACKGROUND = [:bgr_crop_x, :bgr_crop_y, :bgr_crop_w, :bgr_crop_h]

  def is_admin? user
    self.user_organizations.are_admin.find_by(user_id: user.id)
  end

  def set_attr_crop_logo_org x, y, h, w
    self.bgr_crop_x = x
    self.bgr_crop_y = y
    self.bgr_crop_h = h
    self.bgr_crop_w = w
  end

  private
  def should_generate_new_friendly_id?
    slug.blank? || name_changed?
  end
end
