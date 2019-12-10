class LambdaFunction::Api::TasksController < ApplicationController
  protect_from_forgery with: :null_session

  def reminder
    Task.tomorrow_tasks.each do |task|
      member = task.store_member
      if member.line_user_id
        LineBot.new.push_message_with_reminder(task, member.line_user_id)
        puts "line送信（ユーザー:#{member.name}, タスクID:#{task.id}）"
      end
      puts 'メール送信完了' if NotificationMailer.send_remind_task_to_user(task, task.calendar.user, task.calendar).deliver
      puts Time.current
    end
    test_push
  end

  def test
    test_push
    raise
  end

  private
    def test_push
      user_id = ENV['TEST_LINE_USER_ID']
      LineBot.new.push_test(user_id)
      puts 'テストrakeタスク送信'
      puts Time.current
    end
end
