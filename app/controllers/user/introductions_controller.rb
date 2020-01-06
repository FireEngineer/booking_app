class User::IntroductionsController < User::Base
  before_action :authenticate_user!
  before_action :has_calendar?, only:[:new_calendar, :create_calendar]
  before_action :has_staff?, only:[:new_staff, :create_staff]
  skip_before_action :initial_setting_complete?

  def new_calendar
    @user = current_user
    @calendar = @user.calendars.build
    @help_urls = [["アカウント登録", "https://stonly.com/embed/CgZCfgcw8G/view/"]]
  end

  def create_calendar
    @calendar = current_user.calendars.build
    if current_user.update(params_user_calendar)
      flash[:success] = '店鋪登録が完了しました'
      redirect_to introductions_new_staff_url(calendar_id: @calendar.id)
    else
      render :new_calendar
    end
  end

  def new_staff
    @staff = Staff.new
    @help_urls = [["アカウント登録", "https://stonly.com/embed/CgZCfgcw8G/view/"]]
  end

  def create_staff
    @calendar = current_user.calendars.first
    @staff = @calendar.staffs.build(params_staff)
    if @staff.save
      flash[:success] = 'スタッフ登録が完了しました'
      redirect_to introductions_new_task_course_url(calendar_id: @calendar.id)
    else
      render :new_staff
    end
  end

  def new_task_course
    @task_course = TaskCourse.new
    @help_urls = [["アカウント登録", "https://stonly.com/embed/CgZCfgcw8G/view/"]]
  end

  def craete_task_course
    @calendar = current_user.calendars.first
    @task_course = @calendar.task_courses.build(params_task_course)
    if @task_course.save
      flash[:success] = 'コース登録が完了しました'
      redirect_to choice_plan_url
    else
      render :new_task_course
    end
  end

  private

  def params_user_calendar
    params.require(:user).permit(:name, calendars_attributes: [:end_date, :display_week_term, :calendar_name, :phone, :public_uid, :display_interval_time, :end_time, :start_time, :display_time, :address])
  end

  def params_staff
    params.require(:staff).permit(:name, :description, :email, :password, :password_confirmation)
  end

  def params_task_course
    params.require(:task_course).permit(:title, :description, :course_time, :charge)
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
