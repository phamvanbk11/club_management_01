class CreateSponsorDetails < ActiveRecord::Migration[5.0]
  def change
    create_table :sponsor_details do |t|
      t.string :description
      t.integer :money, default: 0
      t.integer :style, default: 0
      t.datetime :deleted_at
      t.references :sponsor, foreign_key: true

      t.timestamps
    end
  end
end
