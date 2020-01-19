class AddIsTaxToTaskCourse < ActiveRecord::Migration[5.2]
  def change
    add_column :task_courses, :is_tax_included, :boolean, default: true, comment: "税込表示かどうか"
    add_column :task_courses, :is_more_than, :boolean, default: false, comment: "以上価格表示かどうか（例：5000円~）"
  end
end
