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
                "type": "bubble",
                "hero": {
                  "type": "image",
                  "url": "https://scdn.line-apps.com/n/channel_devcenter/img/fx/01_1_cafe.png",
                  "size": "full",
                  "aspectRatio": "20:13",
                  "aspectMode": "cover",
                  "action": {
                    "type": "uri",
                    "uri": "http://linecorp.com/"
                  }
                },
                "body": {
                  "type": "box",
                  "layout": "vertical",
                  "contents": [
                    {
                      "type": "text",
                      "text": "Brown Cafe",
                      "weight": "bold",
                      "size": "xl"
                    },
                    {
                      "type": "box",
                      "layout": "baseline",
                      "margin": "md",
                      "contents": [
                        {
                          "type": "icon",
                          "size": "sm",
                          "url": "https://scdn.line-apps.com/n/channel_devcenter/img/fx/review_gold_star_28.png"
                        },
                        {
                          "type": "icon",
                          "size": "sm",
                          "url": "https://scdn.line-apps.com/n/channel_devcenter/img/fx/review_gold_star_28.png"
                        },
                        {
                          "type": "icon",
                          "size": "sm",
                          "url": "https://scdn.line-apps.com/n/channel_devcenter/img/fx/review_gold_star_28.png"
                        },
                        {
                          "type": "icon",
                          "size": "sm",
                          "url": "https://scdn.line-apps.com/n/channel_devcenter/img/fx/review_gold_star_28.png"
                        },
                        {
                          "type": "icon",
                          "size": "sm",
                          "url": "https://scdn.line-apps.com/n/channel_devcenter/img/fx/review_gray_star_28.png"
                        },
                        {
                          "type": "text",
                          "text": "4.0",
                          "size": "sm",
                          "color": "#999999",
                          "margin": "md",
                          "flex": 0
                        }
                      ]
                    },
                    {
                      "type": "box",
                      "layout": "vertical",
                      "margin": "lg",
                      "spacing": "sm",
                      "contents": [
                        {
                          "type": "box",
                          "layout": "baseline",
                          "spacing": "sm",
                          "contents": [
                            {
                              "type": "text",
                              "text": "Place",
                              "color": "#aaaaaa",
                              "size": "sm",
                              "flex": 1
                            },
                            {
                              "type": "text",
                              "text": "Miraina Tower, 4-1-6 Shinjuku, Tokyo",
                              "wrap": true,
                              "color": "#666666",
                              "size": "sm",
                              "flex": 5
                            }
                          ]
                        },
                        {
                          "type": "box",
                          "layout": "baseline",
                          "spacing": "sm",
                          "contents": [
                            {
                              "type": "text",
                              "text": "Time",
                              "color": "#aaaaaa",
                              "size": "sm",
                              "flex": 1
                            },
                            {
                              "type": "text",
                              "text": "10:00 - 23:00",
                              "wrap": true,
                              "color": "#666666",
                              "size": "sm",
                              "flex": 5
                            }
                          ]
                        }
                      ]
                    }
                  ]
                },
                "footer": {
                  "type": "box",
                  "layout": "vertical",
                  "spacing": "sm",
                  "contents": [
                    {
                      "type": "button",
                      "style": "link",
                      "height": "sm",
                      "action": {
                        "type": "uri",
                        "label": "CALL",
                        "uri": "https://linecorp.com"
                      }
                    },
                    {
                      "type": "button",
                      "style": "link",
                      "height": "sm",
                      "action": {
                        "type": "uri",
                        "label": "WEBSITE",
                        "uri": "https://linecorp.com"
                      }
                    },
                    {
                      "type": "spacer",
                      "size": "sm"
                    }
                  ],
                  "flex": 0
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
