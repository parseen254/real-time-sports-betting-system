# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.1].define(version: 2025_03_06_150500) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "bets", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "game_id", null: false
    t.decimal "amount", precision: 10, scale: 2
    t.decimal "odds", precision: 10, scale: 2
    t.integer "status", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "selected_team"
    t.index ["game_id", "status"], name: "index_bets_on_game_id_and_status"
    t.index ["game_id"], name: "index_bets_on_game_id"
    t.index ["status"], name: "index_bets_on_status"
    t.index ["user_id", "status"], name: "index_bets_on_user_id_and_status"
    t.index ["user_id"], name: "index_bets_on_user_id"
  end

  create_table "games", force: :cascade do |t|
    t.string "name"
    t.decimal "odds_home"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.decimal "odds_away"
    t.string "home_team"
    t.string "away_team"
    t.datetime "start_time"
    t.integer "status", default: 0
    t.string "winner"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.decimal "balance", precision: 10, scale: 2, default: "0.0"
    t.string "username", null: false
    t.index ["balance"], name: "index_users_on_balance"
    t.index ["created_at"], name: "index_users_on_created_at"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  add_foreign_key "bets", "games"
  add_foreign_key "bets", "users"
end
