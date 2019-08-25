class CreateTasks < ActiveRecord::Migration[5.2]
  def change
    create_table :tasks do |t|
      t.text :request
      t.datetime :due_at
      t.datetime :start_time
      t.datetime :end_time
      t.string :google_event_id

      t.references :store_member, foreign_key: true
      t.references :task_course, foreign_key: true
      t.references :calendar, foreign_key: true
      t.references :staff, foreign_key: true

      t.timestamps
    end
  end
end
