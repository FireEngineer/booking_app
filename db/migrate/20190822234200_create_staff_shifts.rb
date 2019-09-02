class CreateStaffShifts < ActiveRecord::Migration[5.2]
  def change
    create_table :staff_shifts do |t|
      t.datetime :work_start_time
      t.datetime :work_end_time
      t.date :work_date
      t.references :staff, foreign_key: true

      t.timestamps
    end
  end
end
