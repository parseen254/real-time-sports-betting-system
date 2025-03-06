class AddUserDetails < ActiveRecord::Migration[7.1]
  def change
    change_table :users do |t|
      t.string :username, null: false
      t.decimal :balance, precision: 10, scale: 2, default: 1000.0, null: false
    end

    add_index :users, :username, unique: true
    
    # Add indexes for leaderboard queries
    add_index :users, :balance
    add_index :users, :created_at
  end
end
