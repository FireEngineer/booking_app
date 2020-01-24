class User::CalendarsController < User::Base
  before_action :calendar, except: %i[new create]

  def new
    @calendar = current_user.calendars.build
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
      # スタッフのシフトを作成（base.rbに記載）
      create_calendar_staffs_tasks(@calendar) if @calendar.saved_change_to_display_week_term?
      flash[:succese] = 'カレンダーの設定を更新しました。'
      redirect_to user_calendar_url(@user, @calendar)
    else
      @calendar.reload
      render action: :show
    end
  end

  def update_is_released
    @calendar = Calendar.find_by(public_uid: params[:id])
    if params[:commit] == '公開にする'
      if @calendar.update(is_released: true)
        flash[:succese] = 'カレンダーを公開しました'
        redirect_to user_calendar_dashboard_url(current_user, @calendar)
      end
    else
      if @calendar.update(is_released: false)
        flash[:succese] = 'カレンダーを非公開にしました'
        redirect_to user_calendar_dashboard_url(current_user, @calendar)
      end
    end
  rescue StandardError
    flash[:danger] = '更新できませんでした'
    redirect_to user_calendar_dashboard_url(current_user, @calendar)
  end

  def calendar_preview
    task = Task.new
    @calendar = Calendar.find_by(public_uid: params[:id])
    staff_id = params[:staff_id] || @calendar.staffs.first.id
    @staff = Staff.find(staff_id)
    @task_course = @calendar.task_courses.first
    @user = @calendar.user
    @times = time_interval(@calendar)

    @today = Time.current
    # DBタスクデータを引き出す
    @events = @staff.tasks.map { |task| [task.start_time, task.end_time] }
    # googleカレンダーのデータを同期
    @google_events = SyncCalendarService.new(task, @staff, @calendar).read_event if @staff.google_calendar_id
    one_month = [*Date.current.days_since(@calendar.start_date)..Date.current.weeks_since(@calendar.display_week_term)]
    @month = Kaminari.paginate_array(one_month).page(params[:page]).per(@calendar.end_date)
  end

  private

  def params_calendar
    params.require(:calendar).permit(:start_date, :end_date, :display_week_term, :public_uid, :is_released, :address, :phone, :start_time, :end_time, :display_time, :display_interval_time, :message, :picture)
  end

  def time_interval(calendar)
    start_time = calendar.start_time
    end_time = calendar.end_time
    interval_time = calendar.display_interval_time
    array = []
    1.step do |i|
      array.push(Time.parse("#{start_time}:00") + interval_time.minutes * (i - 1))
      break if Time.parse("#{start_time}:00") + interval_time.minutes * (i - 1) == Time.parse("#{end_time}:00")
    end
    array
  end
end
