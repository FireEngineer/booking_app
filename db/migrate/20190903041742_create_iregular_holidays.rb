class CreateIregularHolidays < ActiveRecord::Migration[5.2]
  def change
    create_table :iregular_holidays do |t|
      t.date :date
      t.text :description

      t.references :calendar_config, foreign_key: true

      t.timestamps
    end
  end
end
