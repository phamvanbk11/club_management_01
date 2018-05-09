class ChangeSponsorColumns < ActiveRecord::Migration[5.0]
  def up
    change_column :sponsors, :sponsor, :integer, default: 0
    remove_column :sponsors, :expense, :integer
  end
end
