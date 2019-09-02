class User::CalendarsController < User::Base
  before_action :calendar, except: %i(new, create)

  def new
    @calendar = current_user.calendars.build()
  end

  def create
    @calendar = current_user.calendars.build(params_calendar)
    if @calenar.save
    end
  end

  def show
    @user = current_user
  end

  def update
    @user = current_user
    if @calendar.update(params_calendar)
      flash[:succese] = "カレンダーの設定を更新しました。"
      redirect_to user_calendar_url(@user, @calendar)
    else
      render action: :index
    end
  end

  private
    def params_calendar
      params.require(:calendar).permit(:start_date, :end_date, :display_week_term, :calender_name, :is_released)
    end

end
