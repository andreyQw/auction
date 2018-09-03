class AddBidWinToLots < ActiveRecord::Migration[5.2]
  def change
    add_column :lots, :bid_win, :integer, null: true
  end
end
