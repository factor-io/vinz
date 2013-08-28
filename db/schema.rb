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

ActiveRecord::Schema.define(version: 20130821213909) do

  create_table "api_keys", force: true do |t|
    t.integer  "key_owner_id"
    t.string   "key_owner_type"
    t.string   "key"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "api_keys", ["key"], name: "api_keys_key_idx"
  add_index "api_keys", ["key_owner_id", "key_owner_type"], name: "index_api_keys_on_key_owner_id_and_key_owner_type"

  create_table "config_items", force: true do |t|
    t.integer  "organization_id"
    t.string   "name"
    t.text     "value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "config_items", ["organization_id"], name: "config_items_organization_id_idx"

  create_table "consumers", force: true do |t|
    t.integer  "organization_id"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "consumers", ["organization_id"], name: "consumers_organization_id_idx"

  create_table "organizations", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: true do |t|
    t.integer  "organization_id"
    t.string   "username"
    t.text     "password"
    t.string   "role"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["organization_id"], name: "users_organization_id_idx"

end
