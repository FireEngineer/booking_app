class User::CalendarsController < User::Base
  before_action :authenticate_user!
  # before_action :check_calendar_info

  def index
    @calendars = current_user.calendars
    @user = current_user
  end

  def update
    @user = current_user
    @calendar = Calendar.find(params[:id])
    if @calendar.update(params_calendar)
      flash[:succese] = "カレンダーの設定を更新しました。"
      redirect_to user_calendars_url(@user)
    else
      render action: :index
    end
  end

  private
    def params_calendar
      params.require(:calendar).permit(:start_date, :end_date, :display_week_term, :calender_name)
    end



end
