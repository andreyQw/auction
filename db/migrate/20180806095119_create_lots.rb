class CreateLots < ActiveRecord::Migration[5.2]
  def change
    create_table :lots do |t|
      t.string :title, null: false
      t.string :image
      t.string :description
      t.integer :status, default: 0, index: true
      t.decimal :current_price, null: false
      t.decimal :estimated_price, null: false
      t.datetime :lot_start_time, null: false
      t.datetime :lot_end_time, null: false

      t.belongs_to :user, foreign_key: true, index: true

      t.timestamps
    end
  end
end
