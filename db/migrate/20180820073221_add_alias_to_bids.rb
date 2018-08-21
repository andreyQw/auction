class AddAliasToBids < ActiveRecord::Migration[5.2]
  def change
    add_column :bids, :nickname, :string
  end
end
