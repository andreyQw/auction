class CreateLots < ActiveRecord::Migration[5.2]
  def change
    create_table :lots do |t|
      t.string :title
      t.string :image
      t.string :description
      t.integer :status, default: 0, index: true
      t.decimal :current_price
      t.decimal :estimated_price
      t.datetime :lot_start_time
      t.datetime :lot_end_time

      t.belongs_to :user, foreign_key: true, index: true

      t.timestamps
    end
  end
end
