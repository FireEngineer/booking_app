class AddLineTokenToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :line_token, :string
  end
end
