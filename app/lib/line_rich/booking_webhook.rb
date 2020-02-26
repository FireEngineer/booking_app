class LineRich::BookingWebhook

  attr_reader :client, :params, :event, :calendar, :courses

  def initialize(client, params, event)
    @client = client
    @params = params
    @calendar = Calendar.find_by(public_uid: params['calendar_uid'])
    @courses = @calendar.task_courses
    @event = event
  end

  def self.call(client, params, event)
    new(client, params, event).call
  end

  def call
    case params['next_step'].to_i
    when 2
      choice_course
    when 3
      choice_staff
    when 4
      choice_date
    when 5
      choice_time
    end
  end

  private

    def choice_course
      message = {
        "type": "flex",
        "altText": "This is a Flex Message",
        "contents": carousel(courses)
      }
      response = client.reply_message(event['replyToken'], message)
      puts response
    end

    def carousel(courses)
      {
        "type": "carousel",
        "contents": contents(courses)
      }
    end
  
    private
  
    def contents(courses)
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

end