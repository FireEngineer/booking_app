class AddClientIdToCalendar < ActiveRecord::Migration[5.2]
  def change
    add_column :calendars, :calendar_id, :string
  end
end
