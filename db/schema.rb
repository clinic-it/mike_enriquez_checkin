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

ActiveRecord::Schema.define(version: 20170831030052) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "blockers", force: :cascade do |t|
    t.integer  "checkin_id",        null: false
    t.integer  "user_id",           null: false
    t.string   "description"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.string   "message_timestamp"
  end

  create_table "checkins", force: :cascade do |t|
    t.date     "checkin_date", null: false
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  create_table "notes", force: :cascade do |t|
    t.integer  "checkin_id",        null: false
    t.integer  "user_id",           null: false
    t.string   "description"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.string   "message_timestamp"
  end

  create_table "projects", force: :cascade do |t|
    t.string   "name",       null: false
    t.integer  "pivotal_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "task_blockers", force: :cascade do |t|
    t.integer  "task_id"
    t.string   "blocker_text"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  create_table "tasks", force: :cascade do |t|
    t.integer  "project_id"
    t.integer  "user_id"
    t.integer  "checkin_id"
    t.string   "title",                                 null: false
    t.string   "url",                                   null: false
    t.string   "current_state"
    t.integer  "estimate",          default: 0
    t.boolean  "current",                               null: false
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
    t.string   "task_type",         default: "feature", null: false
    t.string   "message_timestamp"
    t.integer  "task_id"
  end

  create_table "user_checkins", force: :cascade do |t|
    t.integer  "checkin_id"
    t.integer  "user_id"
    t.string   "screenshot_path"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.string   "message_timestamp"
  end

  create_table "users", force: :cascade do |t|
    t.string   "username",                        null: false
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.string   "fullname"
    t.string   "password_digest"
    t.string   "pivotal_token"
    t.integer  "pivotal_owner_id"
    t.boolean  "admin"
    t.boolean  "active",           default: true
  end

end
