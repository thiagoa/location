# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20140129154734) do

  create_table "catalogs", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "lists", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "location_addresses", force: true do |t|
    t.string   "postal_code"
    t.string   "address"
    t.string   "number"
    t.string   "complement"
    t.integer  "district_id"
    t.decimal  "latitude"
    t.decimal  "longitude"
    t.integer  "addressable_id"
    t.string   "addressable_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "type"
  end

  add_index "location_addresses", ["addressable_type", "addressable_id"], name: "index_location_addressable_id_and_type"
  add_index "location_addresses", ["district_id"], name: "index_location_addresses_on_district_id"

  create_table "location_cities", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "state_id"
    t.boolean  "normalized", default: true
  end

  add_index "location_cities", ["state_id"], name: "index_location_cities_on_state_id"

  create_table "location_districts", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "city_id"
    t.boolean  "normalized", default: true
  end

  add_index "location_districts", ["city_id"], name: "index_location_districts_on_city_id"

  create_table "location_states", force: true do |t|
    t.string   "name"
    t.string   "abbr"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "normalized", default: true
  end

end
