class User::PayjpController < ApplicationController
  before_action :authenticate_user!, except:[:use, :privacy]
  before_action :has_order_plan?, only:[:form]

  layout 'payjp'

  def choice_plan

  end

  def form
    if Plan.find_by(plan_id: params[:plan_params])
      @plan = Plan.find_by(plan_id: params[:plan_params])
    else
      flash[:danger] = "決済パラメーターが不正です"
      redirect_to choice_plan_url
    end
  end

  def create_order
    customer = MyPayjp.create_customer(params["payjp-token"], current_user)
    plan = Plan.find_by(plan_id: params[:plan_id])
    if plan
      response = MyPayjp.create_subscription(customer, plan.plan_id)
      if response["error"]
        flash[:danger] = "決済が完了しませんでした。入力内容を確認して、もう一度やり直してください。"
        redirect_to user_url(current_user)
      else
        order_plan = OrderPlan.create!(user_id: current_user.id, plan_id: plan.id, order_id: response["id"], card_number: customer["cards"]["data"][0]["last4"])
        current_user.calendars.first.update(is_released: true)
        flash[:success] = "決済が完了しました。"
        redirect_to complete_order_url(order_plan)
      end
    else
      flash[:danger] = "決済パラメーターが不正です"
      redirect_to choice_plan_url
    end
  end

  def complete_order
    @order_plan = OrderPlan.find(params[:id])
    @plan = @order_plan.plan
  end

  def show
    @order_plan = OrderPlan.find(params[:id])
    @plan = @order_plan.plan
  end

  def destroy_order_operation
    @order_plan = OrderPlan.find(params[:id])
    @plan = @order_plan.plan
  end

  def destroy_order
    @order_plan = OrderPlan.find(params[:id])
    response = MyPayjp.destroy_subscription(@order_plan)
    if response["error"]
      puts response
      flash[:success] = "有料プランを解約できませんでした。"
    else
      @order_plan.update!(status: 1)
      current_user.calendars.first.update(is_released: false)
      flash[:success] = "有料プランを解約しました。"
    end
    redirect_to user_url(current_user)
  end

  private

    def has_order_plan?
      if current_user.order_plans.any?{ |order_plan| !order_plan.status_destroy? }
        flash[:danger] = "すでにプランに登録済です。"
        redirect_to user_url(current_user)
      end
    end

end
