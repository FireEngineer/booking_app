class AddAdditionalsToCalendarConfigs < ActiveRecord::Migration[5.2]
  def change
    add_column :calendar_configs, :interval_time, :integer, default: 0
  end
end
