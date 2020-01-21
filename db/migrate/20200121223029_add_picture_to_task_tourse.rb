class AddPictureToTaskTourse < ActiveRecord::Migration[5.2]
  def change
    add_column :task_courses, :picture, :string
  end
end
