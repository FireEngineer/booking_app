class CreateLineBots < ActiveRecord::Migration[5.2]
  def change
    create_table :line_bots do |t|
      t.string :channel_id
      t.string :channel_secret

      t.references :admin, foreign_key: true

      t.timestamps
    end
  end
end
