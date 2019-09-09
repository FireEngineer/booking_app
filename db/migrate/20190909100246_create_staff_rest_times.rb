class CreateStaffRestTimes < ActiveRecord::Migration[5.2]
  def change
    create_table :staff_rest_times do |t|
      t.datetime :rest_start_time
      t.datetime :rest_end_time
      t.boolean :is_default, default: false

      t.references :staff_shift, foreign_key: true

      t.timestamps
    end
  end
end
