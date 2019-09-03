class AddAddressToCalendars < ActiveRecord::Migration[5.2]
  def change
    add_column :calendars, :address, :string
    add_column :calendars, :phone, :string
  end
end
