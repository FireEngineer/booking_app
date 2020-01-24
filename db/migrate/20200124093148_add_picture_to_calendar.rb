class AddPictureToCalendar < ActiveRecord::Migration[5.2]
  def change
    add_column :calendars, :picture, :string, comment:"予約完了画面に表示する任意の画像"
    add_column :calendars, :message, :text, comment:"予約完了画面に表示する任意のメッセージ"
  end
end
