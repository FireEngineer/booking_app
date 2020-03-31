module LineRich::Confirm

  def carousel_task(tasks)
    {
      "type": "carousel",
      "contents": contents(tasks)
    }
  end

  private

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

  module_function :carousel_task, :contents

end