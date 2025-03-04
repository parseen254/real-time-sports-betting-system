class CreateBets < ActiveRecord::Migration[7.1]
  def change
    create_table :bets do |t|
      t.references :user, null: false, foreign_key: true
      t.references :game, null: false, foreign_key: true
      t.decimal :amount
      t.integer :odds
      t.integer :status

      t.timestamps
    end
  end
end
