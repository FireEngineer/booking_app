# app.rb
# require 'sinatra'
require 'line/bot'

def client
  @client ||= Line::Bot::Client.new { |config|
    config.channel_id = "1603032553"
    config.channel_secret = "6f3d86e5f90d1e65260bc62728874216"
    config.channel_token = "6ZJmAmDlZpIhPZEnWcX9aO+jy+aDBYbkiENgFe/qPFIHIs5eI+PzC+z3QlCTZV/eZN4lAK74I7Un9CbxSRShJ3NoMs9zk2ORieUuakSvQalD6dbzY2qtQGdFCCzpH4BWvz0PWMCXASXO30dUiaLXHgdB04t89/1O/w1cDnyilFU="
  }
end

post '/callback' do
  body = request.body.read

  signature = request.env['HTTP_X_LINE_SIGNATURE']
  unless client.validate_signature(body, signature)
    error 400 do 'Bad Request' end
  end

  events = client.parse_events_from(body)
  events.each do |event|
    case event
    when Line::Bot::Event::Message
      case event.type
      when Line::Bot::Event::MessageType::Text
        message = {
          type: 'text',
          text: event.message['text']
        }
        client.reply_message(event['replyToken'], message)
      when Line::Bot::Event::MessageType::Image, Line::Bot::Event::MessageType::Video
        response = client.get_message_content(event.message['id'])
        tf = Tempfile.open("content")
        tf.write(response.body)
      end
    end
  end

  # Don't forget to return a successful response
  "OK"
end