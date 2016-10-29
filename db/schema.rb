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

ActiveRecord::Schema.define(version: 20161021000002) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "floorplans", force: :cascade do |t|
    t.string   "name"
    t.text     "description"
    t.integer  "rent"
    t.integer  "bathroom_count"
    t.integer  "bedroom_count"
    t.integer  "property_id"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.index ["property_id"], name: "index_floorplans_on_property_id", using: :btree
  end

  create_table "managements", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "properties", force: :cascade do |t|
    t.string   "name"
    t.text     "description"
    t.string   "formatted_address"
    t.string   "address"
    t.string   "city"
    t.string   "county"
    t.string   "state"
    t.string   "state_code"
    t.string   "zip"
    t.string   "country"
    t.float    "latitude"
    t.float    "longitude"
    t.json     "amenities"
    t.json     "pet"
    t.integer  "rent_min"
    t.integer  "rent_max"
    t.integer  "management_id"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.index ["management_id"], name: "index_properties_on_management_id", using: :btree
  end

  add_foreign_key "floorplans", "properties"
  add_foreign_key "properties", "managements"
end
