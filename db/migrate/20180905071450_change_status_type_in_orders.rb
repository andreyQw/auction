class ChangeStatusTypeInOrders < ActiveRecord::Migration[5.2]
  def self.up
    change_column :orders, :arrival_type, :integer, default: 0 # default("Royal Mail")
  end

  def self.down
    change_column :orders, :arrival_type, :string, default: nil
  end
end
