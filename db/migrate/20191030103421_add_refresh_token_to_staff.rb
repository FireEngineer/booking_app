class AddRefreshTokenToStaff < ActiveRecord::Migration[5.2]
  def change
    add_column :staffs, :refresh_token, :string
  end
end
