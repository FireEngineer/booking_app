class AddChargeToTaskCourses < ActiveRecord::Migration[5.2]
  def change
    add_column :task_courses, :charge, :string
  end
end
