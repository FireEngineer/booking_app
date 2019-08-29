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

ActiveRecord::Schema.define(version: 2019_08_22_234200) do

  create_table "admins", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_admins_on_email", unique: true
    t.index ["reset_password_token"], name: "index_admins_on_reset_password_token", unique: true
  end

  create_table "calendar_configs", force: :cascade do |t|
    t.integer "capacity"
    t.integer "calendar_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["calendar_id"], name: "index_calendar_configs_on_calendar_id"
  end

  create_table "calendars", force: :cascade do |t|
    t.string "calendar_name", default: "予約システム"
    t.integer "start_date", default: 1
    t.integer "end_date", default: 7
    t.integer "display_week_term", default: 3
    t.integer "start_time", default: 10
    t.integer "end_time", default: 22
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "calendar_id"
    t.index ["user_id"], name: "index_calendars_on_user_id"
  end

  create_table "line_bots", force: :cascade do |t|
    t.string "channel_id"
    t.string "channel_secret"
    t.integer "admin_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["admin_id"], name: "index_line_bots_on_admin_id"
  end

  create_table "regular_holidays", force: :cascade do |t|
    t.string "day"
    t.boolean "holiday_flag", default: false
    t.datetime "business_start_at"
    t.datetime "business_end_at"
    t.integer "calendar_config_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["calendar_config_id"], name: "index_regular_holidays_on_calendar_config_id"
  end

  create_table "staff_shifts", force: :cascade do |t|
    t.datetime "work_start_time"
    t.datetime "work_end_time"
    t.date "work_date"
    t.integer "staff_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["staff_id"], name: "index_staff_shifts_on_staff_id"
  end

  create_table "staffs", force: :cascade do |t|
    t.string "name"
    t.integer "calendar_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["calendar_id"], name: "index_staffs_on_calendar_id"
  end

  create_table "store_members", force: :cascade do |t|
    t.string "name"
    t.string "gender"
    t.integer "age"
    t.string "email"
    t.string "phone"
    t.string "line_user_id"
    t.integer "calendar_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["calendar_id"], name: "index_store_members_on_calendar_id"
  end

  create_table "task_courses", force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.integer "course_time"
    t.integer "calendar_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["calendar_id"], name: "index_task_courses_on_calendar_id"
  end

  create_table "tasks", force: :cascade do |t|
    t.text "request"
    t.datetime "due_at"
    t.datetime "start_time"
    t.datetime "end_time"
    t.string "google_event_id"
    t.integer "store_member_id"
    t.integer "task_course_id"
    t.integer "calendar_id"
    t.integer "staff_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["calendar_id"], name: "index_tasks_on_calendar_id"
    t.index ["staff_id"], name: "index_tasks_on_staff_id"
    t.index ["store_member_id"], name: "index_tasks_on_store_member_id"
    t.index ["task_course_id"], name: "index_tasks_on_task_course_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "line_token"
    t.text "client_id"
    t.text "client_secret"
    t.text "google_api_token"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

end
