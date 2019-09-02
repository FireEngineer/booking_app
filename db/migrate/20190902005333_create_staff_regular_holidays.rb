class CreateStaffRegularHolidays < ActiveRecord::Migration[5.2]
  def change
    create_table :staff_regular_holidays do |t|
      t.string :day
      t.boolean :is_holiday
      t.time :work_start_at
      t.time :work_end_at

      t.references :staff, foreign_key: true

      t.timestamps
    end
  end
end
