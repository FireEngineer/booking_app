class CreateConfigs < ActiveRecord::Migration[5.2]
  def change
    create_table :configs do |t|
      t.string :calender_name, default: "予約システム"
      t.integer :start_date, default: 1
      t.integer :end_date, default: 7
      t.integer :display_week_term, default: 3
      t.integer :start_time, default: 10
      t.integer :end_time, default: 22
      
      t.belongs_to :user

      t.timestamps
    end
  end
end
