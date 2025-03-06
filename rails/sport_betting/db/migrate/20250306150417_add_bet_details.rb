class AddBetDetails < ActiveRecord::Migration[7.1]
  def change
    change_table :bets do |t|
      t.string :selected_team
      t.change :status, :integer, default: 0
      t.change :amount, :decimal, precision: 10, scale: 2
      t.change :odds, :decimal, precision: 10, scale: 2
    end

    # Add indexes for performance
    add_index :bets, [:user_id, :status]
    add_index :bets, [:game_id, :status]
    add_index :bets, :status
  end
end
