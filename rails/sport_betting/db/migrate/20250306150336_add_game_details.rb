class AddGameDetails < ActiveRecord::Migration[7.1]
  def change
    change_table :games do |t|
      t.rename :odds, :odds_home
      t.decimal :odds_away
      t.string :home_team
      t.string :away_team
      t.datetime :start_time
      t.integer :status, default: 0
      t.string :winner
    end
  end
end
