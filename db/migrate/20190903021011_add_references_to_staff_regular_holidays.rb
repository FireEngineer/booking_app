class AddReferencesToStaffRegularHolidays < ActiveRecord::Migration[5.2]
  def change
    add_reference :staff_regular_holidays, :regular_holiday, foreign_key: true
  end
end
