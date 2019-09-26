require 'line/bot'
require 'net/http'
require 'uri'
class LineBotByStaff
  include Rails.application.routes.url_helpers

  attr_reader :client
  HOST_URL = if Rails.env == 'production'
               ENV['PRODUCTION_HOST_URL']
             else
               ENV['DEVELOPMENT_HOST_URL']
             end

  def initialize
    channel_secret = ENV['CHANNEL_SECRET']
    channel_token = ENV['CHANNEL_TOKEN']
    @client = initialize_client(channel_secret, channel_token)
  end

  def new; end

  def push_message_with_task_create(task, user_id)
    store_member = task.store_member
    task_course = task.task_course
    staff = task.staff
    user = task.calendar.user
    calendar = task.calendar
    message = {
      "type": "bubble",
      "header": {
        "type": "box",
        "layout": "vertical",
        "contents": [
          {
            "type": "text",
            "text": "Header text"
          }
        ]
      },
      "hero": {
        "type": "image",
        "url": "https://example.com/flex/images/image.jpg"
      },
      "body": {
        "type": "box",
        "layout": "vertical",
        "contents": [
          {
            "type": "text",
            "text": "Body text"
          }
        ]
      },
      "footer": {
        "type": "box",
        "layout": "vertical",
        "contents": [
          {
            "type": "text",
            "text": "Footer text"
          }
        ]
      },
      "styles": {
        "comment": "See the example of a bubble style object"
      }
    }
    response = client.push_message(user_id, message)
  end


  private

  def initialize_client(channel_secret, channel_token)
    client = Line::Bot::Client.new do |config|
      config.channel_secret = channel_secret
      config.channel_token = channel_token
    end
  end
end
