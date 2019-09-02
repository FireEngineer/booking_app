class AddReferencesToTasks < ActiveRecord::Migration[5.2]
  def change
    add_reference :tasks, :user, foreign_key: true
    add_reference :tasks, :store_member, foreign_key: true
    add_reference :tasks, :task_course, foreign_key: true
    add_reference :tasks, :staff, foreign_key: true
  end
end
