class SponsorDetail < ApplicationRecord
  acts_as_paranoid

  belongs_to :sponsor

  enum style: {pay: 0, get: 1}
end
