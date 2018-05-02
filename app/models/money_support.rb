class MoneySupport < ApplicationRecord
  belongs_to :organization
  validates :money, presence: true

  scope :newest, ->{order created_at: :desc}

  serialize :arr_range, Array

  validates :arr_range, presence: true, uniqueness: {scope: :organization}
end
