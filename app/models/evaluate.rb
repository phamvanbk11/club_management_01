class Evaluate < ApplicationRecord
  acts_as_paranoid

  belongs_to :club
  belongs_to :user, ->{with_deleted}
  has_many :evaluate_details, dependent: :destroy
  has_one :money_support_club, dependent: :destroy

  scope :newest, ->{order created_at: :desc}

  delegate :full_name, :avatar, to: :user, prefix: :user
end
