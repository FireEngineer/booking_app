class AddBookingLinkToCalendarConfig < ActiveRecord::Migration[5.2]
  def change
    add_column :calendar_configs, :booking_link, :string
    add_column :calendar_configs, :update_message, :text
    add_column :calendar_configs, :cancel_message, :text
  end
end
