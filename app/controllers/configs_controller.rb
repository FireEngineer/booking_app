class ConfigsController < ApplicationController
  before_action :authenticate_user!
  before_action :check_calendar_info

  def tasks_index
    @tasks = Task.where(user_id: params[:user_id])
  end

  def setting
    @config = current_user.config
    @user = current_user
  end

  def update
    @user = current_user
    @config = current_user.config
    if params[:config]
      if @config.update(params_config)
        flash[:succese] = "カレンダーの設定を更新しました。"
        redirect_to user_setting_url(@user)
      end
    elsif params[:user]
      if @user.update(params_user)
        flash[:succese] = "ユーザーの設定を更新しました。"
        redirect_to user_setting_url(@user)
      end
    end
  end

  private
    def params_config
      params.require(:config).permit(:start_date, :end_date, :display_week_term, :calender_name)
    end

    def params_user
      params.require(:user).permit(:line_token)
    end



end
