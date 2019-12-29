class AgreementMailer < ApplicationMailer
  default from: 'hogehoge@example.com'

  def agreement_to_user(user, order_plan)
    @user = user
    @order_plan = order_plan
    @plan = @order_plan.plan
    mail(
      from: 'tech.leaders.kk@gmail.com',
      to: user.email,
      subject: 'Smart予約契約完了'
    )
  end

  def cancellation_to_user(user, order_plan)
    @user = user
    @order_plan = order_plan
    @plan = @order_plan.plan
    mail(
      from: 'tech.leaders.kk@gmail.com',
      to: user.email,
      subject: 'Smart予約解約手続き完了のお知らせ'
    )
  end

end
