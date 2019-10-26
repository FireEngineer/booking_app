class AddGoogleCalendarToStaff < ActiveRecord::Migration[5.2]
  def change
    add_column :staffs, :client_secret, :text
    add_column :staffs, :client_id, :text
    add_column :staffs, :google_api_token, :text
  end
end
