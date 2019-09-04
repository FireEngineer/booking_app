require 'line/bot'
require 'net/http'
require 'uri'
class LineBot
  attr_reader :client
  if Rails.env == "production"
    HOST_URL = "http://booking-env.6pvxjhkqqx.ap-northeast-1.elasticbeanstalk.com"
  else
    HOST_URL = "http://localhost:3000"
  end

  def initialize()
    channel_secret = "2a3591a3789e3937403903e9dd87cabd"
    channel_token = "s61bzMv2/Ta8mhRMaI9kP08sjtdQ0Kfa99ofal8PyOCa0QaNAnAtfrAmNEGO3bnigM0L7tHsPiqRy548ps8r0SXUPZazJKYhxS5sjle/OQ+2opbgYGrdrDYHZl5oKJQJ4i7n3Hi8XB8L91B1SZU4+AdB04t89/1O/w1cDnyilFU="
    @client = initialize_client(channel_secret, channel_token)
  end

  def new()
  end

  def push_message(task, user_id)

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
        #{HOST_URL}/calendars/#{task.calendar.calendar_name}/tasks/#{task.id}/cancel
      ==================="
    }
    response = client.push_message(user_id, message)
  end

  def push_message_with_edit_task(task, user_id)

    message = {
      type: 'text',
      text: "予約内容を変更しました!
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
        #{HOST_URL}/calendars/#{task.calendar.calendar_name}/tasks/#{task.id}/cancel
      ==================="
    }
    response = client.push_message(user_id, message)
  end

  def push_message_with_delete_task(task, user_id)

    message = {
      type: 'text',
      text: "予約をキャンセルしました!
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
      ==================="
    }
    response = client.push_message(user_id, message)
  end

  private
    def initialize_client(channel_secret, channel_token)
      client = Line::Bot::Client.new { |config|
          config.channel_secret = channel_secret
          config.channel_token = channel_token
      }
    end


end