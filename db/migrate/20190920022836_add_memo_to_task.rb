class AddMemoToTask < ActiveRecord::Migration[5.2]
  def change
    add_column :tasks, :memo, :text
  end
end
