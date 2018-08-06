# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2018_08_06_095154) do

  create_table "bids", force: :cascade do |t|
    t.decimal "proposed_price"
    t.datetime "created_at"
    t.integer "lot_id"
    t.integer "user_id"
    t.index ["lot_id"], name: "index_bids_on_lot_id"
    t.index ["user_id"], name: "index_bids_on_user_id"
  end

  create_table "lots", force: :cascade do |t|
    t.string "title"
    t.string "image"
    t.string "description"
    t.integer "status", default: 0
    t.decimal "current_price"
    t.decimal "estimated_price"
    t.datetime "lot_start_time"
    t.datetime "lot_end_time"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["status"], name: "index_lots_on_status"
    t.index ["user_id"], name: "index_lots_on_user_id"
  end

  create_table "orders", force: :cascade do |t|
    t.integer "status", default: 0
    t.string "arrival_type"
    t.text "arrival_location"
    t.integer "lot_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["lot_id"], name: "index_orders_on_lot_id"
    t.index ["status"], name: "index_orders_on_status"
  end

  create_table "users", force: :cascade do |t|
    t.string "email"
    t.string "password"
    t.string "phone"
    t.string "first_name"
    t.string "last_name"
    t.date "birthday"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
