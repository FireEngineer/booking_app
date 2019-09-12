class AddUniqueIdToCalendar < ActiveRecord::Migration[5.2]
  def change
    add_column :calendars, :unique_id, :string
  end
end
