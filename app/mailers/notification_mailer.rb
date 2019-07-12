class NotificationMailer < ApplicationMailer

  default from: "hogehoge@example.com"

  def send_confirm_to_user(task)
    @task = task
    mail(
      from: "tech.leaders.kk@gmail.com",
      to:   task.email,
      subject: '予約確定通知'
    )
  end

end
