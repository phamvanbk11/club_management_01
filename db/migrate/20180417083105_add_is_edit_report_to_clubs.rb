class AddIsEditReportToClubs < ActiveRecord::Migration[5.0]
  def change
    add_column :clubs, :is_action_report, :boolean, default: false
  end
end
