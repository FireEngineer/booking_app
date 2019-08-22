class CreateStoreMembers < ActiveRecord::Migration[5.2]
  def change
    create_table :store_members do |t|
      t.string :name
      t.string :gender
      t.integer :age
      t.string :email
      t.string :phone
      t.string :line_user_id

      t.references :calendar, foreign_key: true

      t.timestamps
    end
  end
end
