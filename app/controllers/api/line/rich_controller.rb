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
    events = client.parse_events_from(body)
    line_user_id = params['events'][0]['source']['userId']
    store_member = StoreMember.find_by(line_user_id: line_user_id)
    tasks = store_member.tasks.only_valid.future_tasks
    events.each do |event|
      case event
      when Line::Bot::Event::Message
        case event.type
        when Line::Bot::Event::MessageType::Text
          if event.message['text'] == "予約確認"
            if tasks.any?
              message = {
                "type": "flex",
                "altText": "This is a Flex Message",
                "contents": test(tasks)
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
          else
            message = {
              type: 'text',
              text: event.message['text']
            }
            response = client.reply_message(event['replyToken'], message)
            puts response
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

  def test(tasks)
    {
      "type": "carousel",
      "contents": contents(tasks)
    }
  end

  def contents(tasks)
    tasks.map do |task|
      {
        "type": "bubble",
        "header": {
          "type": "box",
          "layout": "vertical",
          "contents": [
            {
              "type": "text",
              "text": "予約"
            }
          ],
          "backgroundColor": "#e8f6fc"
        },
        "body": {
          "type": "box",
          "layout": "vertical",
          "contents": [
            {
              "type": "text",
              "text": "時間",
              "contents": [
                {
                  "type": "span",
                  "text": "店舗"
                },
                {
                  "type": "span",
                  "text": "　　#{task.calendar.calendar_name}"
                }
              ]
            },
            {
              "type": "text",
              "text": "時間",
              "contents": [
                {
                  "type": "span",
                  "text": "時間"
                },
                {
                  "type": "span",
                  "text": "　　#{I18n.l(task.start_time, format: :long)}"
                }
              ]
            },
            {
              "type": "text",
              "text": "時間",
              "contents": [
                {
                  "type": "span",
                  "text": "コース"
                },
                {
                  "type": "span",
                  "text": "　　#{task.task_course.title}"
                }
              ]
            },
            {
              "type": "text",
              "text": "時間",
              "contents": [
                {
                  "type": "span",
                  "text": "料金"
                },
                {
                  "type": "span",
                  "text": "　　#{task.task_course.display_charge}"
                }
              ]
            },
            {
              "type": "text",
              "text": "時間",
              "contents": [
                {
                  "type": "span",
                  "text": "スタッフ"
                },
                {
                  "type": "span",
                  "text": "　　#{task.staff_name}"
                }
              ]
            },
            {
              "type": 'text',
              "text": "予約詳細",
              "action": {
                "type": 'uri',
                "label": 'action',
                "uri": Rails.application.routes.url_helpers.calendar_task_cancel_url(task.calendar, task)
              },
              "color": '#007bff'
            },
          ]
        }
      }
    end
  end

  
end
