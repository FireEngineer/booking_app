class CreateLogPictures < ActiveRecord::Migration[5.2]
  def change
    create_table :log_pictures do |t|
      t.string :picture, comment:"会員のログの写真"

      t.references :member_log, foreign_key: true

      t.timestamps
    end
  end
end
