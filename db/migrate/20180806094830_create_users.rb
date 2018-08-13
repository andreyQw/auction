class CreateUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :users do |t|
      t.string :email, null: false
      t.string :phone, null: false
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.date :birthday, null: false

      t.timestamps
    end
  end
end
