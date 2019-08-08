class CreateCalendarConfigs < ActiveRecord::Migration[5.2]
  def change
    create_table :calendar_configs do |t|
      t.integer :capacity
      
      t.references :calendar, foreign_key: true

      t.timestamps
    end
  end
end
