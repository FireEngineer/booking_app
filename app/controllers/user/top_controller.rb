class User::TopController < User::Base
  before_action :calendar
  before_action :check_staff_course_exsist!
  skip_before_action :authenticate_current_user!

  def dashboard
    @user = current_user
    @staffs = @calendar.staffs
    if current_staff
      @staff = current_staff
    else
      @staff = Staff.find_by(id: params[:staff_id])
    end
    # スタッフの情報を取得
    staff_private = staff_private(@staff)
    staff_shifts = staff_shifts(@staff)
    staff_tasks = staff_tasks(@staff, params[:task_id])
    staff_rests = staff_rests(@staff)
    @events = begin
                (staff_shifts + staff_tasks + staff_rests + staff_private)&.to_json
              rescue StandardError
                (calendar_tasks(@calendar) + calendar_holidays(@calendar)).to_json
              end
              # debugger
    if params[:task_id]
      task_date = Task.find_by(id: params[:task_id]).start_time.to_date
      @current_date = l(task_date, format: :to_json)
    elsif params[:rest_id]
      rest_date = StaffRestTime.find(params[:rest_id]).staff_shift.work_date
      @current_date = l(rest_date, format: :to_json)
    else
      @current_date = l(Date.current, format: :to_json)
    end
    if params[:store_member_id]
      store_member = StoreMember.find(params[:store_member_id])
      flash.now[:warning] = "【#{store_member.name}様：次回予約】時間を選択してください。"
      @store_member_id = store_member.id
    else
      @store_member_id = nil
    end
    @data_calendar = date_range(@calendar)
  end

  private

  # スタッフのシフトのJSON
  def staff_shifts(staff)
    StaffTaskToJsonOutputer.staff_shifts(staff)
  end

  # スタッフの休みのJSON
  def staff_rests(staff)
    StaffTaskToJsonOutputer.staff_rests(staff)
  end

  # スタッフのタスクのJSON
  def staff_tasks(staff, search_id)
    StaffTaskToJsonOutputer.staff_tasks(staff, search_id)
  end

  # スタッフのgoogleカレンダーのプライベートな予定
  def staff_private(staff)
    GoogleEventsToJsonOutputer.staff_private(staff)
  end

  # カレンダー全体のタスクJSON
  def calendar_tasks(calendar)
    CalendarTaskToJsonOutputer.calendar_tasks(calendar)
  end

  # カレンダー全体の休みJSON
  def calendar_holidays(calendar)
    CalendarTaskToJsonOutputer.calendar_holidays(calendar)
  end

  # カレンダーの表示する期間
  def date_range(calendar)
    term = ENV['CALENDAR_DISPLAY_TERM'].to_i #calendar.display_week_term.to_i
    hash = {
      "start_date": Date.current.beginning_of_month,
      "end_date": Date.current.since(term.months).end_of_month
    }.to_json
  end
end
