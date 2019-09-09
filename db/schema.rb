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

ActiveRecord::Schema.define(version: 2019_09_09_100246) do

  create_table "admins", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
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

  create_table "calendar_configs", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "capacity"
    t.bigint "calendar_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "interval_time", default: 0
    t.index ["calendar_id"], name: "index_calendar_configs_on_calendar_id"
  end

  create_table "calendars", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "calendar_name"
    t.integer "start_date", default: 1
    t.integer "end_date", default: 7
    t.integer "display_week_term", default: 3
    t.integer "start_time", default: 9
    t.integer "end_time", default: 18
    t.boolean "is_released", default: false
    t.integer "display_time", default: 5
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "calendar_id"
    t.string "address"
    t.string "phone"
    t.index ["user_id"], name: "index_calendars_on_user_id"
  end

  create_table "iregular_holidays", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.date "date"
    t.text "description"
    t.bigint "calendar_config_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["calendar_config_id"], name: "index_iregular_holidays_on_calendar_config_id"
  end

  create_table "line_bots", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "channel_id"
    t.string "channel_secret"
    t.bigint "admin_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["admin_id"], name: "index_line_bots_on_admin_id"
  end

  create_table "regular_holidays", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "day"
    t.boolean "holiday_flag", default: false
    t.datetime "business_start_at"
    t.datetime "business_end_at"
    t.boolean "is_rest", default: false
    t.datetime "rest_start_time"
    t.datetime "rest_end_time"
    t.bigint "calendar_config_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["calendar_config_id"], name: "index_regular_holidays_on_calendar_config_id"
  end

  create_table "staff_regular_holidays", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "day"
    t.boolean "is_holiday", default: false
    t.time "work_start_at"
    t.time "work_end_at"
    t.boolean "is_rest", default: false
    t.datetime "rest_start_time"
    t.datetime "rest_end_time"
    t.bigint "staff_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "regular_holiday_id"
    t.index ["regular_holiday_id"], name: "index_staff_regular_holidays_on_regular_holiday_id"
    t.index ["staff_id"], name: "index_staff_regular_holidays_on_staff_id"
  end

  create_table "staff_rest_times", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.datetime "rest_start_time"
    t.datetime "rest_end_time"
    t.boolean "is_default", default: false
    t.bigint "staff_shift_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["staff_shift_id"], name: "index_staff_rest_times_on_staff_shift_id"
  end

  create_table "staff_shifts", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.datetime "work_start_time"
    t.datetime "work_end_time"
    t.date "work_date"
    t.bigint "staff_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "is_holiday", default: false
    t.index ["staff_id"], name: "index_staff_shifts_on_staff_id"
  end

  create_table "staffs", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
    t.datetime "deleted_at"
    t.bigint "calendar_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "description"
    t.index ["calendar_id"], name: "index_staffs_on_calendar_id"
  end

  create_table "store_members", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
    t.string "gender"
    t.integer "age"
    t.string "email"
    t.string "phone"
    t.string "line_user_id"
    t.bigint "calendar_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["calendar_id"], name: "index_store_members_on_calendar_id"
  end

  create_table "task_courses", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.integer "course_time"
    t.bigint "calendar_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "charge"
    t.index ["calendar_id"], name: "index_task_courses_on_calendar_id"
  end

  create_table "tasks", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.text "request"
    t.datetime "due_at"
    t.datetime "start_time"
    t.datetime "end_time"
    t.string "google_event_id"
    t.datetime "deleted_at"
    t.bigint "calendar_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.bigint "store_member_id"
    t.bigint "task_course_id"
    t.bigint "staff_id"
    t.index ["calendar_id"], name: "index_tasks_on_calendar_id"
    t.index ["staff_id"], name: "index_tasks_on_staff_id"
    t.index ["store_member_id"], name: "index_tasks_on_store_member_id"
    t.index ["task_course_id"], name: "index_tasks_on_task_course_id"
    t.index ["user_id"], name: "index_tasks_on_user_id"
  end

  create_table "users", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
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

  add_foreign_key "calendar_configs", "calendars"
  add_foreign_key "iregular_holidays", "calendar_configs"
  add_foreign_key "line_bots", "admins"
  add_foreign_key "regular_holidays", "calendar_configs"
  add_foreign_key "staff_regular_holidays", "regular_holidays"
  add_foreign_key "staff_regular_holidays", "staffs"
  add_foreign_key "staff_rest_times", "staff_shifts"
  add_foreign_key "staff_shifts", "staffs"
  add_foreign_key "staffs", "calendars"
  add_foreign_key "store_members", "calendars"
  add_foreign_key "task_courses", "calendars"
  add_foreign_key "tasks", "calendars"
  add_foreign_key "tasks", "staffs"
  add_foreign_key "tasks", "store_members"
  add_foreign_key "tasks", "task_courses"
  add_foreign_key "tasks", "users"
end
