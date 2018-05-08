class AddReferencesClubFrequency < ActiveRecord::Migration[5.0]
  def up
    add_reference :clubs, :frequency, foreign_key: true
    add_reference :club_requests, :frequency, foreign_key: true
  end
end
