class Admin::PlansController < ApplicationController
  def new
    @plan = Plan.new
  end

  def create
    @plan = Plan.new(params_plan)
    if @plan.save!
      response = MyPayjp.create_plan(@plan.charge, interval = 'month')
      @plan.update!(plan_id: response['id'])
      puts response
      flash[:success] = 'プランを作成しました。'
      redirect_to dash_board_top_url(current_admin)
    else
      flash[:success] = 'プランを作成できませんでした'
      redirect_to dash_board_top_url(current_admin)
    end
  end

  def edit
    @plan = Plan.find(params[:id])
  end

  def update
    @plan = Plan.find(params[:id])
    if @plan.update!(params_plan)
      response = MyPayjp.update_plan(@plan) unless @plan.charge == 0
      flash[:success] = 'プランを更新しました。'
      redirect_to dash_board_top_url(current_admin)
    else
      flash[:success] = 'プランを更新できませんでした'
      redirect_to dash_board_top_url(current_admin)
    end
  end

  private

  def params_plan
    params.require(:plan).permit(:title, :charge, :description, :plan_id)
  end
end
