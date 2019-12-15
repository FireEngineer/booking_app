class User::IntroductionsController < User::Base
  before_action :authenticate_user!
  before_action :has_calendar?, only:[:new_calendar, :create_calendar]
  before_action :has_staff?, only:[:new_staff, :create_staff]

  layout 'introduction'

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
    @staff = Staff.new
  end

  def create_staff
    @calendar = current_user.calendars.first
    @staff = @calendar.staffs.build(params_staff)
    if @staff.save
      flash[:success] = 'スタッフ登録が完了しました'
      redirect_to user_calendar_dashboard_url(current_user, @staff.calendar)
    else
      render :new_staff
    end
  end

  private

  def params_calendar
    params.require(:calendar).permit(:start_date, :end_date, :display_week_term, :calendar_name, :phone, :public_uid, :display_interval_time, :end_time, :start_time, :display_time, :address)
  end

  def params_staff
    params.require(:staff).permit(:name, :description, :email, :password, :password_confirmation)
  end

  def has_calendar?
    if current_user.calendars.any?
      redirect_to introductions_new_staff_url
    end
  end

  def has_staff?
    if current_user.calendars.first.staffs.any?
      flash[:notice] = "スタッフは作成済みです。"
      redirect_to user_calendar_dashboard_url(current_user, current_user.calendars.first)
    end
  end

end
