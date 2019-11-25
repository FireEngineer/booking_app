class User::PayjpController < ApplicationController
  before_action :authenticate_user!
  layout 'payjp'

  def form

  end

  def create_order
    customer = MyPayjp.create_customer(params["payjp-token"], current_user)
    plan = Plan.first
    response = MyPayjp.create_subscription(customer, plan.plan_id)
    order_plan = OrderPlan.create!(user_id: current_user.id, plan_id: plan.id, order_id: response["id"], card_number: customer["cards"]["data"][0]["last4"])
    current_user.calendars.first.update(is_released: true)
    redirect_to complete_order_url(order_plan)
  end

  def complete_order
    @order_plan = OrderPlan.find(params[:id])
    @plan = @order_plan.plan
  end

end
