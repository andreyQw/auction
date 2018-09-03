class AddUserWinIdToLots < ActiveRecord::Migration[5.2]
  def change
    add_column :lots, :user_win_id, :integer
  end
end
