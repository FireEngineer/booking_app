class AddAppointToTasks < ActiveRecord::Migration[5.2]
  def change
    add_column :tasks, :is_appoint, :boolean, default: true, comment:"指名予約かどうか"
    add_column :tasks, :is_from_public, :boolean, default: true, comment:"お客からの予約かどうか"
  end
end
