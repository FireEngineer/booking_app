class LineRich::BookingWebhook

  attr_reader :client, :params, :event, :calendar, :courses, :staffs, :dates

  def initialize(client, params, event)
    @client = client
    @params = params
    @calendar = Calendar.find_by(public_uid: params['calendar_uid'])
    @courses = @calendar.task_courses
    @staffs = @calendar.staffs
    @event = event
    @dates = 14.times.map{|n| Date.current.days_ago(n + 1)}.reverse
  end

  def self.call(client, params, event)
    new(client, params, event).call
  end

  def call
    case params['next_step'].to_i
    when 2
      choice_message(courses)
    when 3
      choice_message(staffs)
    when 4
      choice_message(dates)
    when 5
      choice_message(staffs)
    end
  end

  private

    def choice_message(objects)
      message = {
        "type": "flex",
        "altText": "This is a Flex Message",
        "contents": carousel(objects)
      }
      response = client.reply_message(event['replyToken'], message)
      puts response
    end

    def carousel(objects)
      case objects.first.class.name
      when "TaskCourse"
        {
          "type": "carousel",
          "contents": choice_course(objects)
        }
      when "Staff"
        {
          "type": "carousel",
          "contents": choice_staff(objects)
        }
      when "Date"
        {
          "type": "carousel",
          "contents": choice_date(objects)
        }
      end
    end

# ↓コースの選択====================================================
    def choice_course(courses)
      courses.map do |course|
        {
          "type": "bubble",
          "header": {
            "type": "box",
            "layout": "vertical",
            "contents": [
              {
                "type": "text",
                "text": "コースを選択してください。"
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
                    "text": "コース"
                  },
                  {
                    "type": "span",
                    "text": "　　#{course.title}"
                  }
                ]
              },
              {
                "type": "text",
                "text": "料金",
                "contents": [
                  {
                    "type": "span",
                    "text": "コース料金"
                  },
                  {
                    "type": "span",
                    "text": "　　#{course.display_charge}"
                  }
                ]
              },
              {
                "type": "text",
                "text": "時間",
                "contents": [
                  {
                    "type": "span",
                    "text": "コース時間"
                  },
                  {
                    "type": "span",
                    "text": "　　#{course.course_time}"
                  }
                ]
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
                  "type": "postback",
                  "label": "このコースを予約する",
                  "data": "type=booking&next_step=3&calendar_uid=#{calendar.public_uid}&task_course_id=#{course.id}"
                }
              }
            ],
            "flex": 0
          }
        }
      end
    end

# ↓スタッフの選択====================================================
    def choice_staff(staffs)
      staffs.map do |staff|
        {
          "type": "bubble",
          "header": {
            "type": "box",
            "layout": "vertical",
            "contents": [
              {
                "type": "text",
                "text": "スタッフを選択してください。"
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
                    "text": "スタッフ"
                  },
                  {
                    "type": "span",
                    "text": "　　#{staff.name}"
                  }
                ]
              },
              {
                "type": "text",
                "text": "料金",
                "contents": [
                  {
                    "type": "span",
                    "text": "スタッフ説明"
                  },
                  {
                    "type": "span",
                    "text": "　　#{staff.description}"
                  }
                ]
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
                  "type": "postback",
                  "label": "このスタッフを予約する",
                  "data": "type=booking&next_step=4&calendar_uid=#{calendar.public_uid}&task_course_id=#{params['task_course_id']}&staff_id=#{staff.id}"
                }
              }
            ],
            "flex": 0
          }
        }
      end
    end

# ↓日付の選択====================================================
    def choice_date(dates)
      [
        {
          "type": "bubble",
          "header": {
            "type": "box",
            "layout": "vertical",
            "contents": [
              {
                "type": "text",
                "text": "日付を選択してください"
              }
            ]
          },
          "body": {
            "type": "box",
            "layout": "vertical",
            "contents":
              date_contents(dates)
          }
        }
      ]
    end

    def date_contents(dates)
      dates.map do |date|
        {
          "type": "button",
          "action": {
            "type": "postback",
            "label": I18n.l(date, format: :long),
            "data": "type=booking&next_step=4&calendar_uid=#{calendar.public_uid}&task_course_id=#{params['task_course_id']}&staff_id=#{params['task_course_id']}&date=#{date}"
          },
          "style": "link"
        }
      end
    end

end