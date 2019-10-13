class AddBookingMessageToCalendarConfig < ActiveRecord::Migration[5.2]
  def change
    add_column :calendar_configs, :booking_message, :text
  end
end
