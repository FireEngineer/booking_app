class User::PayjpController < ApplicationController
  before_action :authenticate_user!
  layout 'payjp'
  # protect_from_forgery :except => [:payment_callback, :registration_callback]

  def form

  end

  def create_order
    customer = MyPayjp.create_customer(params["payjp-token"], current_user)
    plan = Plan.first
    response = MyPayjp.create_subscription(customer, plan.plan_id)
    debugger
    order_plan = OrderPlan.create!(user_id: current_user.id, plan_id: plan.id, order_id: response["id"])
    redirect_to complete_order_url(order_plan)
  end

  def complete_order
    @order_plan = OrderPlan.find(params[:id])
    @plan = @order_plan.plan
  end

end
