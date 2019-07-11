class CreateTasks < ActiveRecord::Migration[5.2]
  def change
    create_table :tasks do |t|
      t.string :title
      t.text :content
      t.datetime :due_at
      t.references :user, foreign_key: true
      t.string :name
      t.string :email
      t.string :line_id
      t.datetime :date_time
      t.string :phone
      t.string :google_event_id

      t.timestamps
    end
  end
end
