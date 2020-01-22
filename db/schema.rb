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

ActiveRecord::Schema.define(version: 2020_01_22_200333) do

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
    t.integer "capacity", default: 1
    t.integer "cancelable_time", default: 24
    t.bigint "calendar_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "interval_time", default: 0
    t.text "booking_message"
    t.string "booking_link"
    t.text "update_message"
    t.text "cancel_message"
    t.boolean "special_modal_flag", default: false
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
    t.string "public_uid"
    t.integer "display_interval_time", default: 10
    t.index ["public_uid"], name: "index_calendars_on_public_uid", unique: true
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

  create_table "member_pictures", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "picture"
    t.bigint "store_member_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["store_member_id"], name: "index_member_pictures_on_store_member_id"
  end

  create_table "order_plans", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "order_id"
    t.bigint "user_id"
    t.bigint "plan_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "card_number"
    t.integer "status", default: 0, comment: "決済プランのステータス"
    t.index ["plan_id"], name: "index_order_plans_on_plan_id"
    t.index ["user_id"], name: "index_order_plans_on_user_id"
  end

  create_table "orders", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "order_id"
    t.bigint "user_id"
    t.bigint "system_plan_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["system_plan_id"], name: "index_orders_on_system_plan_id"
    t.index ["user_id"], name: "index_orders_on_user_id"
  end

  create_table "plans", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "title"
    t.integer "charge"
    t.text "description"
    t.string "plan_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "trial_days", comment: "トライアル日数"
    t.integer "billing_day", comment: "課金を開始する日（その月の何日から課金するかどうか）"
    t.string "plan_uid", comment: "プランを識別するためのもの"
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
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "line_user_id"
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.text "client_secret"
    t.text "client_id"
    t.text "google_api_token"
    t.string "google_calendar_id"
    t.string "refresh_token"
    t.string "picture", comment: "スタッフ画像"
    t.index ["calendar_id"], name: "index_staffs_on_calendar_id"
    t.index ["confirmation_token"], name: "index_staffs_on_confirmation_token", unique: true
    t.index ["email"], name: "index_staffs_on_email", unique: true
    t.index ["reset_password_token"], name: "index_staffs_on_reset_password_token", unique: true
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
    t.text "memo"
    t.boolean "is_allow_notice"
    t.index ["calendar_id"], name: "index_store_members_on_calendar_id"
  end

  create_table "system_plans", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "title"
    t.string "plan_id"
    t.integer "charge"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "task_courses", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.integer "course_time"
    t.bigint "calendar_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "charge"
    t.boolean "is_tax_included", default: true, comment: "税込表示かどうか"
    t.boolean "is_more_than", default: false, comment: "以上価格表示かどうか（例：5000円~）"
    t.string "picture"
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
    t.text "memo"
    t.boolean "is_sub"
    t.boolean "is_appoint", default: true, comment: "指名予約かどうか"
    t.boolean "is_from_public", default: true, comment: "お客からの予約かどうか"
    t.string "state", comment: "ラインで登録時の検証用乱数"
    t.boolean "is_valid_task", default: true, comment: "有効な予約かどうか"
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
    t.string "member_id"
    t.string "name"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "calendar_configs", "calendars"
  add_foreign_key "iregular_holidays", "calendar_configs"
  add_foreign_key "line_bots", "admins"
  add_foreign_key "member_pictures", "store_members"
  add_foreign_key "order_plans", "plans"
  add_foreign_key "order_plans", "users"
  add_foreign_key "orders", "system_plans"
  add_foreign_key "orders", "users"
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
