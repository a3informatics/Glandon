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

ActiveRecord::Schema.define(version: 2021_01_11_162346) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "ad_hoc_reports", id: :serial, force: :cascade do |t|
    t.string "label"
    t.string "sparql_file"
    t.string "results_file"
    t.datetime "last_run"
    t.boolean "active", default: false
    t.integer "background_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "audit_trails", id: :serial, force: :cascade do |t|
    t.datetime "date_time"
    t.string "user"
    t.string "owner"
    t.string "identifier"
    t.string "version"
    t.integer "event"
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "backgrounds", id: :serial, force: :cascade do |t|
    t.string "description"
    t.boolean "complete", default: false
    t.integer "percentage", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "status"
    t.datetime "started"
    t.datetime "completed"
  end

  create_table "delayed_jobs", id: :serial, force: :cascade do |t|
    t.integer "priority", default: 0, null: false
    t.integer "attempts", default: 0, null: false
    t.text "handler", null: false
    t.text "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string "locked_by"
    t.string "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["priority", "run_at"], name: "delayed_jobs_priority"
  end

  create_table "imports", id: :serial, force: :cascade do |t|
    t.string "type"
    t.string "input_file"
    t.string "output_file"
    t.string "error_file"
    t.string "success_path"
    t.string "error_path"
    t.boolean "success", default: false
    t.integer "background_id"
    t.integer "token_id"
    t.boolean "auto_load", default: false
    t.string "identifier"
    t.string "owner"
    t.integer "file_type", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "name_values", force: :cascade do |t|
    t.string "name"
    t.string "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "notepads", id: :serial, force: :cascade do |t|
    t.string "identifier"
    t.string "useful_1"
    t.string "useful_2"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "note_type"
    t.string "uri_id"
    t.string "uri_ns"
    t.index ["user_id"], name: "index_notepads_on_user_id"
  end

  create_table "old_passwords", id: :serial, force: :cascade do |t|
    t.string "encrypted_password", null: false
    t.string "password_salt"
    t.string "password_archivable_type", null: false
    t.integer "password_archivable_id", null: false
    t.datetime "created_at"
    t.index ["password_archivable_type", "password_archivable_id"], name: "index_password_archivable"
  end

  create_table "tokens", id: :serial, force: :cascade do |t|
    t.datetime "locked_at"
    t.integer "refresh_count"
    t.string "item_uri"
    t.string "item_info"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "user_settings", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "value"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_user_settings_on_user_id"
  end

  create_table "users", id: :serial, force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name"
    t.datetime "password_changed_at"
    t.boolean "is_active", default: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["password_changed_at"], name: "index_users_on_password_changed_at"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "notepads", "users"
  add_foreign_key "user_settings", "users"
end
