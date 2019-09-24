class User::IntroductionsController < User::Base
  def new_calendar
    @calendar = current_user.calendars.build
  end

  def create_calendar
    @calendar = current_user.calendars.build(params_calendar)
    if @calendar.save
      flash[:success] = '店鋪登録が完了しました'
      redirect_to introductions_new_staff_url(calendar_id: @calendar.id)
    else
      render :new_calendar
    end
  end

  def new_staff
    @calendar = Calendar.find(params[:calendar_id])
    @staff = @calendar.staffs.build
  end

  def create_staff
    @staff = Staff.new(params_staff)
    if @staff.save
      flash[:success] = 'スタッフ登録が完了しました'
      redirect_to user_calendar_dashboard_url(current_user, @staff.calendar)
    else
      render :new_staff
    end
  end

  private

  def params_calendar
    params.require(:calendar).permit(:start_date, :end_date, :display_week_term, :calendar_name, :phone, :public_uid)
  end

  def params_staff
    params.require(:staff).permit(:name, :description, :calendar_id, :email, :password, :password_confirmation)
  end
end
