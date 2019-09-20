class AddMemoToStoreMember < ActiveRecord::Migration[5.2]
  def change
    add_column :store_members, :memo, :text
  end
end
