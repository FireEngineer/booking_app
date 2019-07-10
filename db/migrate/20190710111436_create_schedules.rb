class CreateSchedules < ActiveRecord::Migration[5.2]
  def change
    create_table :schedules do |t|
      t.string :title
      t.text :content
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
