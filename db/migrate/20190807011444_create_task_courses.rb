class CreateTaskCourses < ActiveRecord::Migration[5.2]
  def change
    create_table :task_courses do |t|
      t.string :title
      t.text :description
      t.integer :course_time

      t.references :calendar, foreign_key: true

      t.timestamps
    end
  end
end
