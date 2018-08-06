class CreateOrders < ActiveRecord::Migration[5.2]
  def change
    create_table :orders do |t|
      t.integer :status, default: 0, index: true
      t.string :arrival_type
      t.text :arrival_location

      # t.references :lot, foreign_key: true, index: true
      t.belongs_to :lot, foreign_key: true, index: true

      t.timestamps
    end
  end
end
