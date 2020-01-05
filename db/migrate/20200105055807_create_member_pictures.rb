class CreateMemberPictures < ActiveRecord::Migration[5.2]
  def change
    create_table :member_pictures do |t|
      t.string :picture
      t.references :store_member, foreign_key: true

      t.timestamps
    end
  end
end
