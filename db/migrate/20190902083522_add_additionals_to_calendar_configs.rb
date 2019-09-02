class AddAdditionalsToCalendarConfigs < ActiveRecord::Migration[5.2]
  def change
    add_column :calendar_configs, :before_time, :integer, default: 0
    add_column :calendar_configs, :after_time, :integer, default: 0
  end
end
