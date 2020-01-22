require 'line/bot'
require 'net/http'
require 'uri'
class LineBot
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

  def push_message(task, user_id)
    message = message_with_task_create(task)
    response = client.push_message(user_id, message)
  end

  def push_message_with_edit_task(task, user_id)
    message = message_with_task_update(task)
    response = client.push_message(user_id, message)
  end

  def push_message_with_delete_task(task, user_id)
    message = message_with_task_delete(task)
    response = client.push_message(user_id, message)
  end

  def push_message_with_reminder(task, user_id)
    message = message_with_task_reminder(task)
    response = client.push_message(user_id, message)
  end

  def push_test(user_id)
    message = {
      type: 'text',
      text: "test送信
      ===================
      ・名前
        testuser
      ・email
        test@gmail.com
      ・TEL
        000000000000
        #{ENV['RAILS_ENV']}
      ==================="
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

  def message_with_task_create(task)
    store_member = task.store_member
    task_course = task.task_course
    staff = task.staff
    user = task.calendar.user
    calendar = task.calendar
    detail = "担当者：#{task.staff_name},コース：#{task_course.title}"
    {
      "type": "flex",
      "altText": "This is a Flex Message",
      "contents": {
        "type": "bubble",
        "header": {
          "type": "box",
          "layout": "vertical",
          "contents": [
            {
              "type": "text",
              "text": "予約完了通知",
              "size": "lg",
              "color": "#ffffff"
            }
          ],
          "backgroundColor": "#82dd97"
        },
        "body": {
          "type": "box",
          "layout": "vertical",
          "contents": [
            {
              "type": "text",
              "text": "ご予約ありがとうございます。"
            },
            {
              "type": "box",
              "layout": "baseline",
              "spacing": "xxl",
              "contents": [
                {
                  "type": "text",
                  "text": "名前",
                  "color": "#aaaaaa",
                  "size": "md",
                  "flex": 1
                },
                {
                  "type": "text",
                  "text": store_member.name,
                  "wrap": true,
                  "color": "#666666",
                  "size": "md",
                  "flex": 5
                }
              ]
            },
            {
              "type": "box",
              "layout": "baseline",
              "spacing": "xxl",
              "contents": [
                {
                  "type": "text",
                  "text": "email",
                  "color": "#aaaaaa",
                  "size": "md",
                  "flex": 1
                },
                {
                  "type": "text",
                  "text": store_member.email,
                  "wrap": true,
                  "color": "#666666",
                  "size": "md",
                  "flex": 5,
                }
              ]
            },
            {
              "type": "box",
              "layout": "baseline",
              "spacing": "xxl",
              "contents": [
                {
                  "type": "text",
                  "text": "TEL",
                  "color": "#aaaaaa",
                  "size": "md",
                  "flex": 1
                },
                {
                  "type": "text",
                  "text": store_member.phone,
                  "wrap": true,
                  "color": "#666666",
                  "size": "md",
                  "flex": 5,
                }
              ]
            },
            {
              "type": "box",
              "layout": "baseline",
              "spacing": "xxl",
              "contents": [
                {
                  "type": "text",
                  "text": "開始",
                  "color": "#aaaaaa",
                  "size": "md",
                  "flex": 1
                },
                {
                  "type": "text",
                  "wrap": true,
                  "color": "#666666",
                  "size": "md",
                  "flex": 5,
                  "text": I18n.l(task.start_time, format: :long)
                }
              ],
              "width": "100%"
            },
            {
              "type": "box",
              "layout": "baseline",
              "spacing": "xxl",
              "contents": [
                {
                  "type": "text",
                  "text": "終了",
                  "color": "#aaaaaa",
                  "size": "md",
                  "flex": 1,
                  "weight": "regular"
                },
                {
                  "type": "text",
                  "text": I18n.l(task.end_time, format: :long),
                  "wrap": true,
                  "color": "#666666",
                  "size": "md",
                  "flex": 5
                }
              ],
              "width": "100%"
            },
            {
              "type": "box",
              "layout": "baseline",
              "spacing": "xxl",
              "contents": [
                {
                  "type": "text",
                  "text": "コース",
                  "color": "#aaaaaa",
                  "size": "xs",
                  "flex": 1,
                  "align": "start"
                },
                {
                  "type": "text",
                  "text": task_course.title,
                  "wrap": true,
                  "color": "#666666",
                  "size": "md",
                  "flex": 5
                }
              ]
            },
            {
              "type": "box",
              "layout": "baseline",
              "spacing": "xxl",
              "contents": [
                {
                  "type": "text",
                  "text": "担当者",
                  "color": "#aaaaaa",
                  "size": "xs",
                  "flex": 1,
                  "align": "start"
                },
                {
                  "type": "text",
                  "text": task.staff_name,
                  "wrap": true,
                  "color": "#666666",
                  "size": "md",
                  "flex": 5
                }
              ]
            },
            {
              "type": "text",
              "text": calendar.calendar_name,
              "action": {
                "type": "uri",
                "label": "action",
                "uri": Rails.application.routes.url_helpers.calendar_tasks_url(calendar)
              },
              "color": "#007bff"
            },
            {
              "type": "text",
              "text": "googleカレンダーに予定を入れる",
              "action": {
                "type": "uri",
                "label": "action",
                "uri": "https://calendar.google.com/calendar/r/eventedit?text=#{calendar.calendar_name}&details=#{detail}&dates=#{I18n.l(task.start_time, format: :to_google_time)}/#{I18n.l(task.end_time, format: :to_google_time)}&sf=true&openExternalBrowser=1"
              },
              "color": "#098bf2"
            },
            {
              "type": "text",
              "text": calendar.calendar_config.booking_message,
              "wrap": true,
            },
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
                "label": "予約内容を確認",
                "uri": Rails.application.routes.url_helpers.calendar_task_cancel_url(calendar, task)
              }
            },
            {
              "type": "spacer",
              "size": "sm"
            }
          ],
          "flex": 0
        },
        "styles": {
          "footer": {
            "separator": true
          }
        }
      }
    }
  end

  def message_with_task_update(task)
    store_member = task.store_member
    task_course = task.task_course
    staff = task.staff
    user = task.calendar.user
    calendar = task.calendar
    detail = "担当者：#{task.staff_name},コース：#{task_course.title}"
    {
      "type": "flex",
      "altText": "This is a Flex Message",
      "contents": {
        "type": "bubble",
        "header": {
          "type": "box",
          "layout": "vertical",
          "contents": [
            {
              "type": "text",
              "text": "予約変更通知",
              "size": "lg",
              "color": "#ffffff"
            }
          ],
          "backgroundColor": "#cddc39"
        },
        "body": {
          "type": "box",
          "layout": "vertical",
          "contents": [
            {
              "type": "text",
              "text": "予約内容に変更がありました。"
            },
            {
              "type": "box",
              "layout": "baseline",
              "spacing": "xxl",
              "contents": [
                {
                  "type": "text",
                  "text": "名前",
                  "color": "#aaaaaa",
                  "size": "md",
                  "flex": 1
                },
                {
                  "type": "text",
                  "text": store_member.name,
                  "wrap": true,
                  "color": "#666666",
                  "size": "md",
                  "flex": 5
                }
              ]
            },
            {
              "type": "box",
              "layout": "baseline",
              "spacing": "xxl",
              "contents": [
                {
                  "type": "text",
                  "text": "email",
                  "color": "#aaaaaa",
                  "size": "md",
                  "flex": 1
                },
                {
                  "type": "text",
                  "text": store_member.email,
                  "wrap": true,
                  "color": "#666666",
                  "size": "md",
                  "flex": 5,
                }
              ]
            },
            {
              "type": "box",
              "layout": "baseline",
              "spacing": "xxl",
              "contents": [
                {
                  "type": "text",
                  "text": "TEL",
                  "color": "#aaaaaa",
                  "size": "md",
                  "flex": 1
                },
                {
                  "type": "text",
                  "text": store_member.phone,
                  "wrap": true,
                  "color": "#666666",
                  "size": "md",
                  "flex": 5,
                }
              ]
            },
            {
              "type": "box",
              "layout": "baseline",
              "spacing": "xxl",
              "contents": [
                {
                  "type": "text",
                  "text": "開始",
                  "color": "#aaaaaa",
                  "size": "md",
                  "flex": 1
                },
                {
                  "type": "text",
                  "wrap": true,
                  "color": "#666666",
                  "size": "md",
                  "flex": 5,
                  "text": I18n.l(task.start_time, format: :long)
                }
              ],
              "width": "100%"
            },
            {
              "type": "box",
              "layout": "baseline",
              "spacing": "xxl",
              "contents": [
                {
                  "type": "text",
                  "text": "終了",
                  "color": "#aaaaaa",
                  "size": "md",
                  "flex": 1,
                  "weight": "regular"
                },
                {
                  "type": "text",
                  "text": I18n.l(task.end_time, format: :long),
                  "wrap": true,
                  "color": "#666666",
                  "size": "md",
                  "flex": 5
                }
              ],
              "width": "100%"
            },
            {
              "type": "box",
              "layout": "baseline",
              "spacing": "xxl",
              "contents": [
                {
                  "type": "text",
                  "text": "コース",
                  "color": "#aaaaaa",
                  "size": "xs",
                  "flex": 1,
                  "align": "start"
                },
                {
                  "type": "text",
                  "text": task_course.title,
                  "wrap": true,
                  "color": "#666666",
                  "size": "md",
                  "flex": 5
                }
              ]
            },
            {
              "type": "box",
              "layout": "baseline",
              "spacing": "xxl",
              "contents": [
                {
                  "type": "text",
                  "text": "担当者",
                  "color": "#aaaaaa",
                  "size": "xs",
                  "flex": 1,
                  "align": "start"
                },
                {
                  "type": "text",
                  "text": task.staff_name,
                  "wrap": true,
                  "color": "#666666",
                  "size": "md",
                  "flex": 5
                }
              ]
            },
            {
              "type": "text",
              "text": calendar.calendar_name,
              "action": {
                "type": "uri",
                "label": "action",
                "uri": Rails.application.routes.url_helpers.calendar_tasks_url(calendar)
              },
              "color": "#007bff"
            },
            {
              "type": "text",
              "text": "googleカレンダーに予定を入れる",
              "action": {
                "type": "uri",
                "label": "action",
                "uri": "https://calendar.google.com/calendar/r/eventedit?text=#{calendar.calendar_name}&details=#{detail}&dates=#{I18n.l(task.start_time, format: :to_google_time)}/#{I18n.l(task.end_time, format: :to_google_time)}&sf=true&openExternalBrowser=1"
              },
              "color": "#098bf2"
            },
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
                "label": "予約内容を確認",
                "uri": Rails.application.routes.url_helpers.calendar_task_cancel_url(calendar, task)
              }
            },
            {
              "type": "spacer",
              "size": "sm"
            }
          ],
          "flex": 0
        },
        "styles": {
          "footer": {
            "separator": true
          }
        }
      }
    }
  end

  def message_with_task_delete(task)
    store_member = task.store_member
    task_course = task.task_course
    staff = task.staff
    user = task.calendar.user
    calendar = task.calendar
    {
      "type": "flex",
      "altText": "This is a Flex Message",
      "contents": {
        "type": "bubble",
        "header": {
          "type": "box",
          "layout": "vertical",
          "contents": [
            {
              "type": "text",
              "text": "予約キャンセル通知",
              "size": "lg",
              "color": "#ffffff"
            }
          ],
          "backgroundColor": "#9e9e9e"
        },
        "body": {
          "type": "box",
          "layout": "vertical",
          "contents": [
            {
              "type": "text",
              "text": "予約をキャンセルしました。"
            },
            {
              "type": "box",
              "layout": "baseline",
              "spacing": "xxl",
              "contents": [
                {
                  "type": "text",
                  "text": "名前",
                  "color": "#aaaaaa",
                  "size": "md",
                  "flex": 1
                },
                {
                  "type": "text",
                  "text": store_member.name,
                  "wrap": true,
                  "color": "#666666",
                  "size": "md",
                  "flex": 5
                }
              ]
            },
            {
              "type": "box",
              "layout": "baseline",
              "spacing": "xxl",
              "contents": [
                {
                  "type": "text",
                  "text": "email",
                  "color": "#aaaaaa",
                  "size": "md",
                  "flex": 1
                },
                {
                  "type": "text",
                  "text": store_member.email,
                  "wrap": true,
                  "color": "#666666",
                  "size": "md",
                  "flex": 5,
                }
              ]
            },
            {
              "type": "box",
              "layout": "baseline",
              "spacing": "xxl",
              "contents": [
                {
                  "type": "text",
                  "text": "TEL",
                  "color": "#aaaaaa",
                  "size": "md",
                  "flex": 1
                },
                {
                  "type": "text",
                  "text": store_member.phone,
                  "wrap": true,
                  "color": "#666666",
                  "size": "md",
                  "flex": 5,
                }
              ]
            },
            {
              "type": "box",
              "layout": "baseline",
              "spacing": "xxl",
              "contents": [
                {
                  "type": "text",
                  "text": "開始",
                  "color": "#aaaaaa",
                  "size": "md",
                  "flex": 1
                },
                {
                  "type": "text",
                  "wrap": true,
                  "color": "#666666",
                  "size": "md",
                  "flex": 5,
                  "text": I18n.l(task.start_time, format: :long)
                }
              ],
              "width": "100%"
            },
            {
              "type": "box",
              "layout": "baseline",
              "spacing": "xxl",
              "contents": [
                {
                  "type": "text",
                  "text": "終了",
                  "color": "#aaaaaa",
                  "size": "md",
                  "flex": 1,
                  "weight": "regular"
                },
                {
                  "type": "text",
                  "text": I18n.l(task.end_time, format: :long),
                  "wrap": true,
                  "color": "#666666",
                  "size": "md",
                  "flex": 5
                }
              ],
              "width": "100%"
            },
            {
              "type": "box",
              "layout": "baseline",
              "spacing": "xxl",
              "contents": [
                {
                  "type": "text",
                  "text": "コース",
                  "color": "#aaaaaa",
                  "size": "xs",
                  "flex": 1,
                  "align": "start"
                },
                {
                  "type": "text",
                  "text": task_course.title,
                  "wrap": true,
                  "color": "#666666",
                  "size": "md",
                  "flex": 5
                }
              ]
            },
            {
              "type": "box",
              "layout": "baseline",
              "spacing": "xxl",
              "contents": [
                {
                  "type": "text",
                  "text": "担当者",
                  "color": "#aaaaaa",
                  "size": "xs",
                  "flex": 1,
                  "align": "start"
                },
                {
                  "type": "text",
                  "text": task.staff_name,
                  "wrap": true,
                  "color": "#666666",
                  "size": "md",
                  "flex": 5
                }
              ]
            },
            {
              "type": "text",
              "text": calendar.calendar_name,
              "action": {
                "type": "uri",
                "label": "action",
                "uri": Rails.application.routes.url_helpers.calendar_tasks_url(calendar)
              },
              "color": "#007bff"
            },
          ]
        },
      }
    }
  end

  def message_with_task_reminder(task)
    store_member = task.store_member
    task_course = task.task_course
    staff = task.staff
    user = task.calendar.user
    calendar = task.calendar
    {
      "type": "flex",
      "altText": "This is a Flex Message",
      "contents": {
        "type": "bubble",
        "header": {
          "type": "box",
          "layout": "vertical",
          "contents": [
            {
              "type": "text",
              "text": "予約リマインド通知",
              "size": "lg",
              "color": "#ffffff"
            }
          ],
          "backgroundColor": "#f7e333"
        },
        "body": {
          "type": "box",
          "layout": "vertical",
          "contents": [
            {
              "type": "text",
              "text": "明日の予約のリマインド通知です。"
            },
            {
              "type": "box",
              "layout": "baseline",
              "spacing": "xxl",
              "contents": [
                {
                  "type": "text",
                  "text": "名前",
                  "color": "#aaaaaa",
                  "size": "md",
                  "flex": 1
                },
                {
                  "type": "text",
                  "text": store_member.name,
                  "wrap": true,
                  "color": "#666666",
                  "size": "md",
                  "flex": 5
                }
              ]
            },
            {
              "type": "box",
              "layout": "baseline",
              "spacing": "xxl",
              "contents": [
                {
                  "type": "text",
                  "text": "email",
                  "color": "#aaaaaa",
                  "size": "md",
                  "flex": 1
                },
                {
                  "type": "text",
                  "text": store_member.email,
                  "wrap": true,
                  "color": "#666666",
                  "size": "md",
                  "flex": 5,
                }
              ]
            },
            {
              "type": "box",
              "layout": "baseline",
              "spacing": "xxl",
              "contents": [
                {
                  "type": "text",
                  "text": "TEL",
                  "color": "#aaaaaa",
                  "size": "md",
                  "flex": 1
                },
                {
                  "type": "text",
                  "text": store_member.phone,
                  "wrap": true,
                  "color": "#666666",
                  "size": "md",
                  "flex": 5,
                }
              ]
            },
            {
              "type": "box",
              "layout": "baseline",
              "spacing": "xxl",
              "contents": [
                {
                  "type": "text",
                  "text": "開始",
                  "color": "#aaaaaa",
                  "size": "md",
                  "flex": 1
                },
                {
                  "type": "text",
                  "wrap": true,
                  "color": "#666666",
                  "size": "md",
                  "flex": 5,
                  "text": I18n.l(task.start_time, format: :long)
                }
              ],
              "width": "100%"
            },
            {
              "type": "box",
              "layout": "baseline",
              "spacing": "xxl",
              "contents": [
                {
                  "type": "text",
                  "text": "終了",
                  "color": "#aaaaaa",
                  "size": "md",
                  "flex": 1,
                  "weight": "regular"
                },
                {
                  "type": "text",
                  "text": I18n.l(task.end_time, format: :long),
                  "wrap": true,
                  "color": "#666666",
                  "size": "md",
                  "flex": 5
                }
              ],
              "width": "100%"
            },
            {
              "type": "box",
              "layout": "baseline",
              "spacing": "xxl",
              "contents": [
                {
                  "type": "text",
                  "text": "コース",
                  "color": "#aaaaaa",
                  "size": "xs",
                  "flex": 1,
                  "align": "start"
                },
                {
                  "type": "text",
                  "text": task_course.title,
                  "wrap": true,
                  "color": "#666666",
                  "size": "md",
                  "flex": 5
                }
              ]
            },
            {
              "type": "box",
              "layout": "baseline",
              "spacing": "xxl",
              "contents": [
                {
                  "type": "text",
                  "text": "担当者",
                  "color": "#aaaaaa",
                  "size": "xs",
                  "flex": 1,
                  "align": "start"
                },
                {
                  "type": "text",
                  "text": task.staff_name,
                  "wrap": true,
                  "color": "#666666",
                  "size": "md",
                  "flex": 5
                }
              ]
            },
            {
              "type": "text",
              "text": calendar.calendar_name,
              "action": {
                "type": "uri",
                "label": "action",
                "uri": Rails.application.routes.url_helpers.calendar_tasks_url(calendar)
              },
              "color": "#007bff"
            },
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
                "label": "予約内容を確認",
                "uri": Rails.application.routes.url_helpers.calendar_task_cancel_url(calendar, task)
              }
            },
            {
              "type": "spacer",
              "size": "sm"
            }
          ],
          "flex": 0
        },
        "styles": {
          "footer": {
            "separator": true
          }
        }
      }
    }
  end


end
