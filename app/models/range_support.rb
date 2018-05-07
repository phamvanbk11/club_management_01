class RangeSupport < ApplicationRecord
  belongs_to :organization

  validates :value_from, presence: true
  validates :value_to, presence: true
  validates :style, presence: true

  enum style: {evaluate_point: 1, member: 2}
  enum operator: {range: 0, less_than: 1, more_than: 2, less_than_or_equal: 3,
    more_than_or_equal: 4}

  scope :newest, ->{order created_at: :desc}
end
