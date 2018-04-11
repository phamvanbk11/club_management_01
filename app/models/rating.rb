class Rating < ApplicationRecord
  belongs_to :rateable, polymorphic: true
  belongs_to :user, ->{with_deleted}

  has_many :activities, as: :trackable, dependent: :destroy

  def self.avg_rate new_rate, club
    (club.rating.to_f * club.ratings.size + new_rate.to_i) / (club.ratings.size + 1)
  end
end
