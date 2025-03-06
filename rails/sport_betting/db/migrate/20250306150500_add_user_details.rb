class AddUserDetails < ActiveRecord::Migration[7.1]
  def change
    change_table :users do |t|
      t.string :username, null: false
    end

    add_index :users, :username, unique: true
    add_index :users, :created_at
    
    # Add index for balance that was added in previous migration
    add_index :users, :balance
  end
end
