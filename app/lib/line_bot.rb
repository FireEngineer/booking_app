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
    message = {
      type: 'text',
      text: "予約ありがとうございます!
      ===================
      ・名前
        #{task.store_member.name}
      ・email
        #{task.store_member.email}
      ・TEL
        #{task.store_member.phone}
      ・開始時間
        #{task.start_time.strftime('%Y年%-m月%-d日 %H:%M')}~
        #{task.end_time.strftime('%H:%M')}
      ・コース名
        #{task.task_course.title}
      ・コース料金
        #{task.task_course.charge}
      ・担当者
        #{task.staff.name}
      ・キャンセルURL
        #{HOST_URL}/calendars/#{task.calendar.public_uid}/tasks/#{task.id}/cancel
      ==================="
    }
    response = client.push_message(user_id, message)
  end

  def push_message_with_edit_task(task, user_id)
    message = {
      type: 'text',
      text: "予約内容を変更しました!
      ===================
      ・名前
        #{task.store_member.name}
      ・email
        #{task.store_member.email}
      ・TEL
        #{task.store_member.phone}
      ・開始時間
        #{task.start_time.strftime('%Y年%-m月%-d日 %H:%M')}~
        #{task.end_time.strftime('%H:%M')}
      ・コース名
        #{task.task_course.title}
      ・コース料金
        #{task.task_course.charge}
      ・担当者
        #{task.staff.name}
      ・キャンセルURL
        #{HOST_URL}/calendars/#{task.calendar.public_uid}/tasks/#{task.id}/cancel
      ==================="
    }
    response = client.push_message(user_id, message)
  end

  def push_message_with_delete_task(task, user_id)
    message = {
      type: 'text',
      text: "予約をキャンセルしました!
      ===================
      ・名前
        #{task.store_member.name}
      ・email
        #{task.store_member.email}
      ・TEL
        #{task.store_member.phone}
      ・開始時間
        #{task.start_time.strftime('%Y年%-m月%-d日 %H:%M')}~
        #{task.end_time.strftime('%H:%M')}
      ・コース名
        #{task.task_course.title}
      ・コース料金
        #{task.task_course.charge}
      ・担当者
        #{task.staff.name}
      ==================="
    }
    response = client.push_message(user_id, message)
  end

  def push_message_with_reminder(task, user_id)
    message = {
      type: 'text',
      text: "明日の予約内容のお知らせ。
      ===================
      ・名前
        #{task.store_member.name}
      ・email
        #{task.store_member.email}
      ・TEL
        #{task.store_member.phone}
      ・開始時間
        #{task.start_time.strftime('%Y年%-m月%-d日 %H:%M')}~
        #{task.end_time.strftime('%H:%M')}
      ・コース名
        #{task.task_course.title}
      ・コース料金
        #{task.task_course.charge}
      ・担当者
        #{task.staff.name}
      ・キャンセルURL
        #{HOST_URL}/calendars/#{task.calendar.public_uid}/tasks/#{task.id}/cancel
      ==================="
    }
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
end
