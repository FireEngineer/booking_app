class Admin::DashBoardsController < Admin::Base
  def top
    @admin = Admin.find(params[:id])
    @plans = Plan.all
    @users = User.all
  end
end
