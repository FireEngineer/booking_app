class AddDescriptionsToStaffs < ActiveRecord::Migration[5.2]
  def change
    add_column :staffs, :description, :text
  end
end
