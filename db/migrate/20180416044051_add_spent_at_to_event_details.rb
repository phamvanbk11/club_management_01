class AddSpentAtToEventDetails < ActiveRecord::Migration[5.0]
  def change
    add_column :event_details, :spent_at, :date
  end
end
