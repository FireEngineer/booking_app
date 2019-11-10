class AddSpecialModalFlagToCalendarConfig < ActiveRecord::Migration[5.2]
  def change
    add_column :calendar_configs, :special_modal_flag, :boolean, default: false
  end
end
