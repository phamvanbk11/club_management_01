class AddAutoCreateToEvents < ActiveRecord::Migration[5.0]
  def change
    add_column :events, :is_auto_create, :boolean, default: false
  end
end
