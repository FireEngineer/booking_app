class CreateStaffRegularHolidays < ActiveRecord::Migration[5.2]
  def change
    create_table :staff_regular_holidays do |t|
      t.string :day
      t.boolean :is_holiday, default: false
      t.time :work_start_at
      t.time :work_end_at
      t.boolean :is_rest, default: false
      t.datetime :rest_start_time
      t.datetime :rest_end_time

      t.references :staff, foreign_key: true

      t.timestamps
    end
  end
end
