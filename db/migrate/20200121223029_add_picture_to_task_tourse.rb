class AddPictureToTaskTourse < ActiveRecord::Migration[5.2]
  def change
    add_column :task_courses, :picture, :string, comment:"画像用"
  end
end
