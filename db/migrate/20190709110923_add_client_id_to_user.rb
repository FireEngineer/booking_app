class AddClientIdToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :client_id, :text
    add_column :users, :client_secret, :text
  end
end
