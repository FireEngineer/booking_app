class AddIsHolidayToStaffShifts < ActiveRecord::Migration[5.2]
  def change
    add_column :staff_shifts, :is_holiday, :boolean, default: false
  end
end
