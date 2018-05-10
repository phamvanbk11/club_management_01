class Album < ApplicationRecord
  has_many :images, dependent: :destroy
  has_many :videos, dependent: :destroy
  has_many :activities, as: :trackable, dependent: :destroy

  belongs_to :club
  belongs_to :event

  validates :name, presence: true, length: {minimum: Settings.min_name}

  scope :newest, ->{order created_at: :desc}
  scope :other, ->id{where.not id: id}
  accepts_nested_attributes_for :images

  def is_in_club? club
    self.club == club
  end
end
