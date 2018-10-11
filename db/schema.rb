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

ActiveRecord::Schema.define(version: 2018_10_11_033831) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "blockers", id: :serial, force: :cascade do |t|
    t.integer "checkin_id", null: false
    t.integer "user_id", null: false
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "message_timestamp"
  end

  create_table "checkins", id: :serial, force: :cascade do |t|
    t.date "checkin_date", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "notes", id: :serial, force: :cascade do |t|
    t.integer "checkin_id", null: false
    t.integer "user_id", null: false
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "message_timestamp"
  end

  create_table "projects", id: :serial, force: :cascade do |t|
    t.string "name", null: false
    t.integer "pivotal_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "task_blockers", id: :serial, force: :cascade do |t|
    t.integer "task_id"
    t.string "blocker_text"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "tasks", id: :serial, force: :cascade do |t|
    t.integer "project_id"
    t.integer "user_id"
    t.integer "checkin_id"
    t.string "title", null: false
    t.string "url", null: false
    t.string "current_state"
    t.integer "estimate", default: 0
    t.boolean "current", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "task_type", default: "feature", null: false
    t.string "message_timestamp"
    t.integer "task_id"
  end

  create_table "user_checkins", id: :serial, force: :cascade do |t|
    t.integer "checkin_id"
    t.integer "user_id"
    t.string "screenshot_path"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "message_timestamp"
  end

  create_table "users", id: :serial, force: :cascade do |t|
    t.string "username", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "fullname"
    t.string "password_digest"
    t.string "pivotal_token"
    t.integer "pivotal_owner_id"
    t.boolean "admin"
    t.boolean "active", default: true
    t.string "freshbooks_token"
    t.string "freshbooks_task_id"
  end

end
