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
    tasks = store_member.tasks.where("start_time > ?", Time.current)
    events.each do |event|
      case event
      when Line::Bot::Event::Message
        case event.type
        when Line::Bot::Event::MessageType::Text
          if event.message['text'] == "予約確認"
            tasks.each do |task|
              message = {
                "type": "template",
                "altText": "this is a carousel template",
                "template": {
                    "type": "carousel",
                    "columns": [
                        {
                          "thumbnailImageUrl": "https://example.com/bot/images/item1.jpg",
                          "imageBackgroundColor": "#FFFFFF",
                          "title": "this is menu",
                          "text": "description",
                          "defaultAction": {
                              "type": "uri",
                              "label": "View detail",
                              "uri": "http://example.com/page/123"
                          },
                          "actions": [
                              {
                                  "type": "postback",
                                  "label": "Buy",
                                  "data": "action=buy&itemid=111"
                              },
                              {
                                  "type": "postback",
                                  "label": "Add to cart",
                                  "data": "action=add&itemid=111"
                              },
                              {
                                  "type": "uri",
                                  "label": "View detail",
                                  "uri": "http://example.com/page/111"
                              }
                          ]
                        },
                        {
                          "thumbnailImageUrl": "https://example.com/bot/images/item2.jpg",
                          "imageBackgroundColor": "#000000",
                          "title": "this is menu",
                          "text": "description",
                          "defaultAction": {
                              "type": "uri",
                              "label": "View detail",
                              "uri": "http://example.com/page/222"
                          },
                          "actions": [
                              {
                                  "type": "postback",
                                  "label": "Buy",
                                  "data": "action=buy&itemid=222"
                              },
                              {
                                  "type": "postback",
                                  "label": "Add to cart",
                                  "data": "action=add&itemid=222"
                              },
                              {
                                  "type": "uri",
                                  "label": "View detail",
                                  "uri": "http://example.com/page/222"
                              }
                          ]
                        }
                    ],
                    "imageAspectRatio": "rectangle",
                    "imageSize": "cover"
                }
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

  def task_message(task)
    str2 = <<-EOS
      ・予約時間
      #{l(task.start_time, format: :middle)}~
      #{l(task.end_time, format: :middle)}
      ・予約コース
      #{task.task_course.title}
      ・コース料金
      #{task.task_course.charge}
      ・担当スタッフ
      #{task.staff_name}
    EOS
  end

  def test
    {
      "type": "carousel",
      "contents": [
        {
          "type": "bubble",
          "header": {
            "type": "box",
            "layout": "vertical",
            "contents": [
              {
                "type": "text",
                "text": "予約内容",
                "style": "normal",
                "weight": "regular",
                "size": "lg"
              }
            ]
          },
          "body": {
            "type": "box",
            "layout": "vertical",
            "contents": [
              {
                "type": "text",
                "text": "予約時間",
                "contents": [
                  {
                    "type": "span",
                    "text": "時間"
                  },
                  {
                    "type": "span",
                    "text": "　　　予約時間"
                  }
                ]
              },
              {
                "type": "text",
                "text": "予約時間",
                "contents": [
                  {
                    "type": "span",
                    "text": "コース"
                  },
                  {
                    "type": "span",
                    "text": "　　　予約時間"
                  }
                ]
              },
              {
                "type": "text",
                "text": "予約時間",
                "contents": [
                  {
                    "type": "span",
                    "text": "料金"
                  },
                  {
                    "type": "span",
                    "text": "　　　予約時間"
                  }
                ]
              },
              {
                "type": "text",
                "text": "予約時間",
                "contents": [
                  {
                    "type": "span",
                    "text": "スタッフ"
                  },
                  {
                    "type": "span",
                    "text": "　　　予約時間"
                  }
                ]
              }
            ]
          },
          "styles": {
            "header": {
              "separator": true,
              "backgroundColor": "#27d8f7"
            }
          }
        },
        {
          "type": "bubble",
          "body": {
            "type": "box",
            "layout": "vertical",
            "contents": [
              {
                "type": "text",
                "text": "hello, world"
              }
            ]
          }
        }
      ]
    }
  end

  
end
