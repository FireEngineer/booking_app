class AddPictureToStaff < ActiveRecord::Migration[5.2]
  def change
    add_column :staffs, :picture, :string, comment:"スタッフ画像"
  end
end
