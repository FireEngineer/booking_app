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
    store_member = StoreMember.find(line_user_id: line_user_id)
    tasks = store_member.tasks.where("start_time > ?", Time.current)
    events.each do |event|
      case event
      when Line::Bot::Event::Message
        case event.type
        when Line::Bot::Event::MessageType::Text
          if event.message['text'] == "予約確認"
            tasks.each do |task|
              message = {
                type: 'text',
                text: task_message(task)
              }
              client.reply_message(event['replyToken'], message)
            end
          else
            message = {
              type: 'text',
              text: event.message['text']
            }
          end
        end
      end
      response = client.reply_message(event['replyToken'], message)
      puts response
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

  
end
