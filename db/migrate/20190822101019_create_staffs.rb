class CreateStaffs < ActiveRecord::Migration[5.2]
  def change
    create_table :staffs do |t|
      t.string :name
      t.datetime :deleted_at

      t.references :calendar, foreign_key: true

      t.timestamps
    end
  end
end
