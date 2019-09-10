class CreateCalendarConfigs < ActiveRecord::Migration[5.2]
  def change
    create_table :calendar_configs do |t|
      t.integer :capacity, default: 1
      t.integer :cancelable_time, default: 24
      
      t.references :calendar, foreign_key: true

      t.timestamps
    end
  end
end
