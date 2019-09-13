class AddPublicUidToCalendar < ActiveRecord::Migration[5.2]
  def change
    add_column :calendars, :public_uid, :string
    add_index  :calendars, :public_uid, unique: true
  end
end
