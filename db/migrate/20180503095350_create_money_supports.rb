class CreateMoneySupports < ActiveRecord::Migration[5.0]
  def change
    create_table :money_supports do |t|
      t.integer :money, default: 0
      t.string :arr_range
      t.references :organization, foreign_key: true

      t.timestamps
    end
  end
end
