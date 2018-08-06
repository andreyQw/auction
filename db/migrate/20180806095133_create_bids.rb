class CreateBids < ActiveRecord::Migration[5.2]
  def change
    create_table :bids do |t|

      t.decimal :proposed_price
      t.datetime :created_at

      t.belongs_to :lot, foreign_key: true, index: true
      t.belongs_to :user, foreign_key: true, index: true
    end
  end
end
