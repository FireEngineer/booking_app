class User::IntroductionsController < User::Base
    before_action :authenticate_user!

    def new_calendar
      @calendar = current_user.calendars.build()
    end

    def create_calendar
      @calendar = current_user.calendars.build(params_calendar)
      if @calendar.save
        flash[:success] = "アカウント登録が完了しました"
        redirect_to user_calendar_dashboard_url(current_user, @calendar)
      else
        render :new
      end
    end

    private
    def params_calendar
      params.require(:calendar).permit(:start_date, :end_date, :display_week_term, :calendar_name)
    end
end
