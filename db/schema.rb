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

ActiveRecord::Schema.define(version: 2019_04_15_234335) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "games", force: :cascade do |t|
    t.string "name", null: false
    t.integer "bgg_id", null: false
    t.text "description"
    t.string "thumbnail"
    t.string "image"
    t.integer "year_published"
    t.integer "min_players"
    t.integer "max_players"
    t.integer "playtime"
    t.boolean "bgg_data_collected", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "shop_games", force: :cascade do |t|
    t.integer "game_id"
    t.integer "shop_id"
    t.string "url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "shops", force: :cascade do |t|
    t.string "name"
    t.string "url"
    t.string "phone"
    t.string "country"
    t.string "region"
    t.string "city"
    t.text "raw_data"
    t.text "raw_followup"
    t.boolean "has_cart"
    t.boolean "has_site"
    t.boolean "url_valid"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "search_string"
  end

end
