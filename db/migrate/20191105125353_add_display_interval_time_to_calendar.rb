class AddDisplayIntervalTimeToCalendar < ActiveRecord::Migration[5.2]
  def change
    add_column :calendars, :display_interval_time, :integer, default: 10
  end
end
