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
    message = message_with_task_create(task)
    response = client.push_message(user_id, message)
  end

  def push_message_with_task_cancel(task, user_id)
    message = message_with_task_cancel(task)
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
    {
      "type": 'flex',
      "altText": 'This is a Flex Message',
      "contents": {
        "type": 'bubble',
        "header": {
          "type": 'box',
          "layout": 'vertical',
          "contents": [
            {
              "type": 'text',
              "text": '予約通知',
              "size": 'xl',
              "color": '#ffffff'
            }
          ],
          "backgroundColor": '#057ef6'
        },
        "body": {
          "type": 'box',
          "layout": 'vertical',
          "contents": [
            {
              "type": 'box',
              "layout": 'baseline',
              "spacing": 'xxl',
              "contents": [
                {
                  "type": 'text',
                  "text": '名前',
                  "color": '#aaaaaa',
                  "size": 'md',
                  "flex": 1
                },
                {
                  "type": 'text',
                  "text": "#{store_member.name}様",
                  "wrap": true,
                  "color": '#666666',
                  "size": 'md',
                  "flex": 5
                }
              ]
            },
            {
              "type": 'box',
              "layout": 'baseline',
              "spacing": 'xxl',
              "contents": [
                {
                  "type": 'text',
                  "text": 'email',
                  "color": '#aaaaaa',
                  "size": 'md',
                  "flex": 1
                },
                {
                  "type": 'text',
                  "text": store_member.email,
                  "wrap": true,
                  "color": '#007bff',
                  "size": 'md',
                  "flex": 5,
                  "action": {
                    "type": 'uri',
                    "label": 'action',
                    "uri": "mailto:#{store_member.email}"
                  }
                }
              ]
            },
            {
              "type": 'box',
              "layout": 'baseline',
              "spacing": 'xxl',
              "contents": [
                {
                  "type": 'text',
                  "text": 'TEL',
                  "color": '#aaaaaa',
                  "size": 'md',
                  "flex": 1
                },
                {
                  "type": 'text',
                  "text": store_member.phone,
                  "wrap": true,
                  "color": '#007bff',
                  "size": 'md',
                  "flex": 5,
                  "action": {
                    "type": 'uri',
                    "label": 'action',
                    "uri": "tel:#{store_member.phone}"
                  }
                }
              ]
            },
            {
              "type": 'box',
              "layout": 'baseline',
              "spacing": 'xxl',
              "contents": [
                {
                  "type": 'text',
                  "text": '開始',
                  "color": '#aaaaaa',
                  "size": 'md',
                  "flex": 1
                },
                {
                  "type": 'text',
                  "wrap": true,
                  "color": '#666666',
                  "size": 'md',
                  "flex": 5,
                  "text": I18n.l(task.start_time, format: :long)
                }
              ],
              "width": '100%'
            },
            {
              "type": 'box',
              "layout": 'baseline',
              "spacing": 'xxl',
              "contents": [
                {
                  "type": 'text',
                  "text": '終了',
                  "color": '#aaaaaa',
                  "size": 'md',
                  "flex": 1,
                  "weight": 'regular'
                },
                {
                  "type": 'text',
                  "text": I18n.l(task.end_time, format: :long),
                  "wrap": true,
                  "color": '#666666',
                  "size": 'md',
                  "flex": 5
                }
              ],
              "width": '100%'
            },
            {
              "type": 'box',
              "layout": 'baseline',
              "spacing": 'xxl',
              "contents": [
                {
                  "type": 'text',
                  "text": 'コース',
                  "color": '#aaaaaa',
                  "size": 'xs',
                  "flex": 1,
                  "align": 'start'
                },
                {
                  "type": 'text',
                  "text": task_course.title,
                  "wrap": true,
                  "color": '#666666',
                  "size": 'md',
                  "flex": 5
                }
              ]
            }
          ]
        },
        "footer": {
          "type": 'box',
          "layout": 'vertical',
          "spacing": 'sm',
          "contents": [
            {
              "type": 'button',
              "style": 'link',
              "height": 'sm',
              "action": {
                "type": 'uri',
                "label": '予約を確認',
                "uri": Rails.application.routes.url_helpers.user_calendar_dashboard_url(user, calendar, staff_id: staff.id, task_id: task.id)
              }
            },
            {
              "type": 'spacer',
              "size": 'sm'
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

  def message_with_task_cancel(task)
    store_member = task.store_member
    task_course = task.task_course
    staff = task.staff
    user = task.calendar.user
    calendar = task.calendar
    {
      "type": 'flex',
      "altText": 'This is a Flex Message',
      "contents": {
        "type": 'bubble',
        "header": {
          "type": 'box',
          "layout": 'vertical',
          "contents": [
            {
              "type": 'text',
              "text": 'キャンセル通知',
              "size": 'xl',
              "color": '#ffffff'
            }
          ],
          "backgroundColor": '#989797'
        },
        "body": {
          "type": 'box',
          "layout": 'vertical',
          "contents": [
            {
              "type": 'text',
              "text": '以下の内容の予約がキャンセルされました。'
            },
            {
              "type": 'box',
              "layout": 'baseline',
              "spacing": 'xxl',
              "contents": [
                {
                  "type": 'text',
                  "text": '名前',
                  "color": '#aaaaaa',
                  "size": 'md',
                  "flex": 1
                },
                {
                  "type": 'text',
                  "text": "#{store_member.name}様",
                  "wrap": true,
                  "color": '#666666',
                  "size": 'md',
                  "flex": 5
                }
              ]
            },
            {
              "type": 'box',
              "layout": 'baseline',
              "spacing": 'xxl',
              "contents": [
                {
                  "type": 'text',
                  "text": 'email',
                  "color": '#aaaaaa',
                  "size": 'md',
                  "flex": 1
                },
                {
                  "type": 'text',
                  "text": store_member.email,
                  "wrap": true,
                  "color": '#007bff',
                  "size": 'md',
                  "flex": 5,
                  "action": {
                    "type": 'uri',
                    "label": 'action',
                    "uri": "mailto:#{store_member.email}"
                  }
                }
              ]
            },
            {
              "type": 'box',
              "layout": 'baseline',
              "spacing": 'xxl',
              "contents": [
                {
                  "type": 'text',
                  "text": 'TEL',
                  "color": '#aaaaaa',
                  "size": 'md',
                  "flex": 1
                },
                {
                  "type": 'text',
                  "text": store_member.phone,
                  "wrap": true,
                  "color": '#007bff',
                  "size": 'md',
                  "flex": 5,
                  "action": {
                    "type": 'uri',
                    "label": 'action',
                    "uri": "tel:#{store_member.phone}"
                  }
                }
              ]
            },
            {
              "type": 'box',
              "layout": 'baseline',
              "spacing": 'xxl',
              "contents": [
                {
                  "type": 'text',
                  "text": '開始',
                  "color": '#aaaaaa',
                  "size": 'md',
                  "flex": 1
                },
                {
                  "type": 'text',
                  "wrap": true,
                  "color": '#666666',
                  "size": 'md',
                  "flex": 5,
                  "text": I18n.l(task.start_time, format: :long)
                }
              ],
              "width": '100%'
            },
            {
              "type": 'box',
              "layout": 'baseline',
              "spacing": 'xxl',
              "contents": [
                {
                  "type": 'text',
                  "text": '終了',
                  "color": '#aaaaaa',
                  "size": 'md',
                  "flex": 1,
                  "weight": 'regular'
                },
                {
                  "type": 'text',
                  "text": I18n.l(task.end_time, format: :long),
                  "wrap": true,
                  "color": '#666666',
                  "size": 'md',
                  "flex": 5
                }
              ],
              "width": '100%'
            },
            {
              "type": 'box',
              "layout": 'baseline',
              "spacing": 'xxl',
              "contents": [
                {
                  "type": 'text',
                  "text": 'コース',
                  "color": '#aaaaaa',
                  "size": 'xs',
                  "flex": 1,
                  "align": 'start'
                },
                {
                  "type": 'text',
                  "text": task_course.title,
                  "wrap": true,
                  "color": '#666666',
                  "size": 'md',
                  "flex": 5
                }
              ]
            }
          ]
        }
      }
    }
  end
end
