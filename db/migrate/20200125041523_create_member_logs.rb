class CreateMemberLogs < ActiveRecord::Migration[5.2]
  def change
    create_table :member_logs do |t|
      t.text :log_text, comment:"会員情報のログメモ"

      t.references :store_member, foreign_key: true

      t.timestamps
    end
  end
end
