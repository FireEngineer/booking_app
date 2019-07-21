class AddLineTokenToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :line_token, :string
    add_column :users, :client_id, :text
    add_column :users, :client_secret, :text
    add_column :users, :google_api_token, :text
  end
end
