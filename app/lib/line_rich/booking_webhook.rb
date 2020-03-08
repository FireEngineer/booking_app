class LineRich::BookingWebhook

  attr_reader :client, :params, :event, :calendar, :courses, :course, :staffs, :staff, :dates, :date, :time

  def initialize(client, params, event)
    @client = client
    @params = params
    @calendar = Calendar.find_by(public_uid: params['calendar_uid'])
    @courses = @calendar.task_courses
    @course = TaskCourse.find(params['task_course_id']) if params['task_course_id']
    @staffs = @calendar.staffs
    @staff = Staff.find(params['staff_id']) if params['staff_id']
    @event = event
    @dates = 14.times.map{|n| Date.current.days_since(n + 1)}.reverse
    @date = params['date'].to_date if params['date']
    @time = params['time'].to_date if params['time']
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
      choice_message(date)
    when 6
      choice_message(nil)
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
      case params['next_step'].to_i
      when 2
        {
          "type": "carousel",
          "contents": choice_course(objects)
        }
      when 3
        {
          "type": "carousel",
          "contents": choice_staff(objects)
        }
      when 4
        {
          "type": "carousel",
          "contents": choice_date(objects)
        }
      when 5
        {
          "type": "carousel",
          "contents": choice_time(objects)
        }
      when 6
        {
          "type": "carousel",
          "contents": confirm
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
                  "data": "type=booking&next_step=4&calendar_uid=#{calendar.public_uid}&task_course_id=#{course.id}&staff_id=#{staff.id}"
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
            "data": "type=booking&next_step=5&calendar_uid=#{calendar.public_uid}&task_course_id=#{course.id}&staff_id=#{staff.id}&date=#{date}"
          },
          "style": "link"
        }
      end
    end

# ↓時間の選択====================================================

    def choice_time(date)
      [
        {
          "type": "bubble",
          "header": {
            "type": "box",
            "layout": "vertical",
            "contents": [
              {
                "type": "text",
                "text": "時間を選択してください"
              }
            ]
          },
          "body": {
            "type": "box",
            "layout": "vertical",
            "contents":
            test
          }
        }
      ]
    end

    def test
      staff.get_reservable_times(course, date).map do |time|
        {
          "type": "button",
          "action": {
            "type": "postback",
            "label": "#{time}",
            "data": "type=booking&next_step=5&calendar_uid=#{calendar.public_uid}&task_course_id=#{course.id}&staff_id=#{staff.id}&date=#{date}&time=#{time}"
          },
          "style": "link"
        }
      end
    end

# ↓時間の選択====================================================

    def confirm
      [
        {
          "type": "bubble",
          "header": {
            "type": "box",
            "layout": "vertical",
            "contents": [
              {
                "type": "text",
                "text": "予約内容の確認"
              }
            ],
            "backgroundColor": "#c0e8f7"
          },
          "body": {
            "type": "box",
            "layout": "vertical",
            "contents": [
              {
                "type": "text",
                "text": "店舗名　　テスト"
              },
              {
                "type": "text",
                "text": "コース　　テスト"
              },
              {
                "type": "text",
                "text": "スタッフ　テスト"
              },
              {
                "type": "text",
                "text": "開始時間　テスト"
              },
              {
                "type": "text",
                "text": "終了時間　テスト"
              },
              {
                "type": "text",
                "text": "料金　　テスト"
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
                  "type": "postback",
                  "label": "予約確定する",
                  "data": "type=booking&next_step=5&calendar_uid=#{calendar.public_uid}&task_course_id=#{course.id}&staff_id=#{staff.id}&date=#{date}&time=#{time}"
                }
              },
              {
                "type": "button",
                "style": "link",
                "height": "sm",
                "action": {
                  "type": "postback",
                  "label": "内容を変更する",
                  "data": "type=booking&next_step=5&calendar_uid=#{calendar.public_uid}&task_course_id=#{course.id}&staff_id=#{staff.id}&date=#{date}&time=#{time}"
                }
              },
              {
                "type": "button",
                "action": {
                  "type": "postback",
                  "label": "キャンセル",
                  "data": "type=booking&next_step=5&calendar_uid=#{calendar.public_uid}&task_course_id=#{course.id}&staff_id=#{staff.id}&date=#{date}&time=#{time}"
                }
              }
            ],
            "flex": 0
          }
        }
      ]
    end

end