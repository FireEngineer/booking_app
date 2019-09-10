namespace :task_reminder do
    desc "リマインダー配信"
    task push: :environment do
        # 翌日のタスクを検索して、リマインド通知
        Task.where("start_time > ? && start_time <= ?", Time.current, Time.current.tomorrow.end_of_day.to_time).each do |task|
            member = task.store_member
            if member.line_user_id
                LineBot.new().push_message_with_reminder(task, member.line_user_id)
                puts "line送信（ユーザー:#{member.name}, タスクID:#{task.id}）"
            end
            if NotificationMailer.send_remind_task_to_user(task, task.calendar.user, task.calendar).deliver
                puts "メール送信完了"
            end
            puts Time.current
        end
    end

    desc "リマインダー配信test"
    task test: :environment do
        user_id = ENV['TEST_LINE_USER_ID']
        LineBot.new().push_test(user_id)
        puts "テストrakeタスク送信"
        puts Time.current
    end
end
