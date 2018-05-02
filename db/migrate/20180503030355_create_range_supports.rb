class CreateRangeSupports < ActiveRecord::Migration[5.0]
  def change
    create_table :range_supports do |t|
      t.integer :operator, default: 0
      t.integer :value_from, default: 0
      t.integer :value_to, default: 0
      t.integer :style
      t.references :organization, foreign_key: true

      t.timestamps
    end
  end
end
