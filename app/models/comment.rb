class Comment < ApplicationRecord
  acts_as_paranoid

  belongs_to :user, ->{with_deleted}
  belongs_to :target, polymorphic: true

  scope :newest, ->{order created_at: :desc}
end
