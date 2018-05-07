class AddFrequencyToClubs < ActiveRecord::Migration[5.0]
  def change
    add_column :clubs, :frequency, :integer, default: 0
    add_column :club_requests, :frequency, :integer, default: 0
  end
end
