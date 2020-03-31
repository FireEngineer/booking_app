class LambdaFunction::Api::TasksController < ApplicationController
  protect_from_forgery with: :null_session

  def reminder
    tasks = Task.only_valid.tomorrow_tasks.each do |task|
      member = task.store_member
      if member.line_user_id
        LineBot.new.push_message_with_reminder(task, member.line_user_id)
        puts "line送信（ユーザー:#{member.name}, タスクID:#{task.id}）"
      end
      puts 'メール送信完了' if NotificationMailer.send_remind_task_to_user(task, task.calendar.user, task.calendar).deliver
      puts Time.current
    end
    message = (tasks.any? ? "配信リマインダー数：#{tasks.size}" : "配信リマインダー数：0")
    LineBot.new.push_test(message)
    { statusCode: 200, body: JSON.generate('リマインド完了！') }
  end

  def test
    LineBot.new.push_test("テストリマインダー")
  end
  
end
