module LineRich::Booking

  def start_booking(calendars)
    {
      "type": "bubble",
      "header": {
        "type": "box",
        "layout": "vertical",
        "contents": [
          {
            "type": "text",
            "text": "店舗名を選択してください。"
          }
        ]
      },
      "body": {
        "type": "box",
        "layout": "vertical",
        "contents": calendars_array(calednars),
      }
    }
  end

  private

    def calendars_array(calednars)
      calednars.map do |calendar|
        {
          "type": "button",
          "action": {
            "type": "postback",
            "label": calendar.calendar_name,
            "data": "type=booking&next_step=2&calendar_uid=#{calendar.public_uid}"
          }
        }
      end
    end

    module_function :start_booking, :calendars_array

end