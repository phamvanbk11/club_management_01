class MoneySupportClub < ApplicationRecord
  belongs_to :club
  belongs_to :evaluate

  serialize :user_ids, Array
end
