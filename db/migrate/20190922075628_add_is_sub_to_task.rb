class AddIsSubToTask < ActiveRecord::Migration[5.2]
  def change
    add_column :tasks, :is_sub, :boolean
  end
end
