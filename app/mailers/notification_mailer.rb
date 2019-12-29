class NotificationMailer < ApplicationMailer
  default from: ENV['EMAIL']

  def send_confirm_to_user(task, user, calendar)
    @task = task
    @user = user
    @calendar = calendar
    mail(
      from: ENV['EMAIL'],
      to: task.store_member.email,
      subject: '予約確定通知'
    )
  end

  def send_edit_task_to_user(task, user, calendar)
    @task = task
    @user = user
    @calendar = calendar
    mail(
      from: ENV['EMAIL'],
      to: task.store_member.email,
      subject: '予約内容変更通知'
    )
  end

  def send_delete_task_to_user(task, user, calendar)
    @task = task
    @user = user
    @calendar = calendar
    mail(
      from: ENV['EMAIL'],
      to: task.store_member.email,
      subject: '予約キャンセル通知'
    )
  end

  def send_remind_task_to_user(task, user, calendar)
    @task = task
    @user = user
    @calendar = calendar
    mail(
      from: ENV['EMAIL'],
      to: task.store_member.email,
      subject: '明日の予約リマインド'
    )
  end
end
