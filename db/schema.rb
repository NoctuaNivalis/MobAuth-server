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

ActiveRecord::Schema.define(version: 20140811093441) do

  create_table "devices", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
  end

  add_index "devices", ["user_id"], name: "index_devices_on_user_id"

  create_table "tokens", force: true do |t|
    t.string   "code",       null: false
    t.integer  "device_id",  null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "tokens", ["code"], name: "index_tokens_on_code", unique: true
  add_index "tokens", ["device_id"], name: "index_tokens_on_device_id"

  create_table "users", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end