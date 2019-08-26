require 'line/bot'
require 'net/http'
require 'uri'
class LineBot


  def self.push_message(task, user_id)

    message = {
      type: 'text',
      text: "予約ありがとうございます!
      ===================
      ・名前
        #{task.store_member.name}
      ・email
        #{task.store_member.email}
      ・TEL
        #{task.store_member.phone}
      ・開始時間
        #{task.start_time.strftime("%Y年%-m月%-d日 %H:%M")}~
        #{task.end_time.strftime("%H:%M")}
      ・キャンセルURL
        #{ if Rails.env == "development" then "http://localhost:3000/calendars/#{task.calendar.calendar_name}/tasks/#{task.id}/cancel" end }
      ==================="
    }

    # message = {
    #   "type": "template",
    #   "altText": "This is a buttons template",
    #   "template": {
    #       "type": "buttons",
    #       "thumbnailImageUrl": "https://example.com/bot/images/image.jpg",
    #       "imageAspectRatio": "rectangle",
    #       "imageSize": "cover",
    #       "imageBackgroundColor": "#FFFFFF",
    #       "title": "Menu",
    #       "text": "Please select",
    #       # "defaultAction": {
    #       #     "type": "uri",
    #       #     "label": "View detail",
    #       #     "uri": "http://example.com/page/123"
    #       # },
    #       "actions": [
    #           {
    #             "type": "uri",
    #             "label": "キャンセル",
    #             "uri": "#{ if Rails.env == "development" then "http://localhost:3000/calendars/#{task.calendar.calendar_name}/tasks/#{task.id}/cancel" end }"
    #           }
    #       ]
    #   }
    # }
    client = Line::Bot::Client.new { |config|
        config.channel_secret = "2a3591a3789e3937403903e9dd87cabd"
        config.channel_token = "s61bzMv2/Ta8mhRMaI9kP08sjtdQ0Kfa99ofal8PyOCa0QaNAnAtfrAmNEGO3bnigM0L7tHsPiqRy548ps8r0SXUPZazJKYhxS5sjle/OQ+2opbgYGrdrDYHZl5oKJQJ4i7n3Hi8XB8L91B1SZU4+AdB04t89/1O/w1cDnyilFU="
    }
    response = client.push_message(user_id, message)
  end

  private

  def message(task)
    message = <<-TEXT
        
      TEXT
    message
  end

end

  # # Don't forget to return a successful response
  # "OK"