# frozen_string_literal: true

class AddIndexToStaffs < ActiveRecord::Migration[5.2]
  def change
    add_index :staffs, :email,                unique: true
    add_index :staffs, :reset_password_token, unique: true
    add_index :staffs, :confirmation_token,   unique: true
    # add_index :staffs, :unlock_token,         unique: true
  end
end
