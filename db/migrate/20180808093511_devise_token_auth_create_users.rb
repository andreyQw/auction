class DeviseTokenAuthCreateUsers < ActiveRecord::Migration[5.2]
  def change
    change_table(:users) do |t|
      ## Required
      t.string :provider, null: false, default: "email"
      t.string :uid, null: false, default: ""

      ## Database authenticatable
      t.string :encrypted_password, null: false, default: ""

      ## Recoverable
      t.string   :reset_password_token
      t.datetime :reset_password_sent_at
      t.boolean  :allow_password_change, default: false

      ## Rememberable
      t.datetime :remember_created_at

      ## Trackable
      t.integer  :sign_in_count, default: 0, null: false
      t.datetime :current_sign_in_at
      t.datetime :last_sign_in_at
      t.string   :current_sign_in_ip
      t.string   :last_sign_in_ip

      ## Confirmable
      t.string   :confirmation_token
      t.datetime :confirmed_at
      t.datetime :confirmation_sent_at
      t.string   :unconfirmed_email # Only if using reconfirmable

      ## Lockable
      # t.integer  :failed_attempts, :default => 0, :null => false # Only if lock strategy is :failed_attempts
      # t.string   :unlock_token # Only if unlock strategy is :email or :both
      # t.datetime :locked_at

      ## User Info
      # t.string :email, null: false
      # t.string :password, null: false
      # t.string :phone, null: false
      # t.string :first_name, null: false
      # t.string :last_name, null: false
      # t.date :birthday, null: false
      # t.timestamps

      ## Tokens
      t.text :tokens

      # updates the user table immediately with the above defaults
      User.reset_column_information
      # finds all existing users and updates them.
      # if you change the default values above you'll also have to change them here below:
      User.find_each do |user|
        user.uid = user.email
        user.provider = "email"
        user.save!
      end
    end

    add_index :users, :email,                unique: true
    add_index :users, [:uid, :provider],     unique: true
    add_index :users, :reset_password_token, unique: true
    add_index :users, :confirmation_token,   unique: true
    # add_index :users, :unlock_token,       unique: true
  end
end
