class Api::Line::RichController < ApplicationController
  require 'line/bot'
  protect_from_forgery
  skip_before_action :verify_authenticity_token

  def webhook
    body = request.body.read
    signature = request.env['HTTP_X_LINE_SIGNATURE']
    unless client.validate_signature(body, signature)
      error 400 do 'Bad Request' end
    end
    @events = client.parse_events_from(body)
    @line_user_id = params['events'][0]['source']['userId']
    @store_member = StoreMember.find_by(line_user_id: line_user_id)
    @events.each do |event|
      case event
      when Line::Bot::Event::Postback
        puts params['events']['postback']['data']
        if params['events']['postback']['data']['type'] == 'booking'
          test_reply(msg, event)
        end
      when Line::Bot::Event::Message
        case event.type
        when Line::Bot::Event::MessageType::Text
          if event.message['text'] == "予約確認"
            tasks = @store_member.tasks.only_valid.future_tasks
            confirm_task(tasks, event)
          elsif event.message['text'] == "予約する"
            calendars = Calendar.joins(:store_members).where(store_members: {line_user_id: @line_user_id}).distinct
            start_booking_reply(calendars, event)
          else
            normal_reply_message(event)
          end
        end
      end
    end
    head :ok
  end

private

# LINE Developers登録完了後に作成される環境変数の認証
  def client
    @client ||= Line::Bot::Client.new { |config|
      config.channel_secret = ENV["CHANNEL_SECRET"]
      config.channel_token = ENV["CHANNEL_TOKEN"]
    }
  end

  def confirm_task(tasks, event)
    if tasks.any?
      message = {
        "type": "flex",
        "altText": "This is a Flex Message",
        "contents": LineRich::Confirm.carousel_task(tasks)
      }
      response = client.reply_message(event['replyToken'], message)
      puts response
    else
      message = {
        type: '予約はございません。ご予約お待ちしております！',
        text: event.message['text']
      }
      response = client.reply_message(event['replyToken'], message)
      puts response
    end
  end

  def normal_reply_message(event)
    message = {
      type: 'text',
      text: event.message['text']
    }
    response = client.reply_message(event['replyToken'], message)
    puts response
  end

  def start_booking_reply(calendars, event)
    if calendars.any?
      message = {
        "type": "flex",
        "altText": "This is a Flex Message",
        "contents": LineRich::Booking.start_booking(calendars)
      }
      response = client.reply_message(event['replyToken'], message)
      puts response
    else
      message = {
        type: '登録されている店舗がありません。',
        text: event.message['text']
      }
      response = client.reply_message(event['replyToken'], message)
      puts response
    end
  end

  def test_reply(msg, event)
    message = {
      type: '登録されている店舗がありません。',
      text: msg
    }
    response = client.reply_message(event['replyToken'], message)
    puts response
  end

  
end
