class AddStateToTasks < ActiveRecord::Migration[5.2]
  def change
    add_column :tasks, :state, :string, comment: "ラインで登録時の検証用乱数"
    add_column :tasks, :is_valid_task, :boolean, default: true, comment: "有効な予約かどうか"
  end
end
