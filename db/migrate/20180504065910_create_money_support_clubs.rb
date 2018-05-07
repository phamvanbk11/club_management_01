class CreateMoneySupportClubs < ActiveRecord::Migration[5.0]
  def change
    create_table :money_support_clubs do |t|
      t.references :club, foreign_key: true
      t.references :evaluate, foreign_key: true
      t.integer :money
      t.integer :time
      t.integer :year
      t.text :user_ids

      t.timestamps
    end
  end
end
