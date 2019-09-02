class CreateRegularHolidays < ActiveRecord::Migration[5.2]
  def change
    create_table :regular_holidays do |t|
      t.string :day
      t.boolean :holiday_flag, default: false
      t.datetime :business_start_at
      t.datetime :business_end_at



      t.references :calendar_config, foreign_key: true

      t.timestamps
    end
  end
end
