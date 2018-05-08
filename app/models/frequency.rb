class Frequency < ApplicationRecord
  belongs_to :organization
  has_many :clubs, dependent: :nullify
  has_many :club_requests, dependent: :nullify

  validates :value_from, presence: true
  validates :value_to, presence: true

  enum operator: {range: 0, less_than: 1, more_than: 2, less_than_or_equal: 3,
    more_than_or_equal: 4}

  scope :by_organization, ->organization_id{where organization_id: organization_id}
end
