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

ActiveRecord::Schema[7.0].define(version: 2023_03_14_092305) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "bookings", force: :cascade do |t|
    t.bigint "bookmark_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "pack_advice"
    t.index ["bookmark_id"], name: "index_bookings_on_bookmark_id"
  end

  create_table "bookmarks", force: :cascade do |t|
    t.text "description"
    t.bigint "route_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["route_id"], name: "index_bookmarks_on_route_id"
  end

  create_table "days", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.float "latitude"
    t.float "longitude"
    t.bigint "route_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.float "price"
    t.string "city"
    t.string "nation"
    t.string "name_hotel"
    t.text "description_hotel"
    t.float "latitude_hotel"
    t.float "longitude_hotel"
    t.float "price_hotel"
    t.string "room_type"
    t.integer "no_of_rooms"
    t.integer "sequence"
    t.index ["route_id"], name: "index_days_on_route_id"
  end

  create_table "routes", force: :cascade do |t|
    t.string "destination"
    t.float "total_price", default: 0.0
    t.date "start_date"
    t.date "end_date"
    t.float "budget"
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "no_of_people"
    t.string "hotel_pref"
    t.index ["user_id"], name: "index_routes_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "first_name"
    t.string "last_name"
    t.string "passport_no"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "bookings", "bookmarks"
  add_foreign_key "bookmarks", "routes"
  add_foreign_key "days", "routes"
  add_foreign_key "routes", "users"
end
