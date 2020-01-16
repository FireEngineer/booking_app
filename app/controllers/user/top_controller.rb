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
    if @staff
      @events = (staff_shifts + staff_tasks + staff_rests + staff_private)&.to_json
    else
      @events = (calendar_tasks(@calendar) + calendar_holidays(@calendar)).to_json
    end
    if params[:task_id]
      task_date = Task.only_valid.find_by(id: params[:task_id]).start_time.to_date
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
    @help_urls = [["店舗側予約方法", "https://stonly.com/sl/00cf73dc-2622-4c44-8e4e-96d8a637f0af/Steps/"],
                  ["ドラッグ＆ドロップによる、予約時間の変更", "https://stonly.com/sl/3cdb59f3-7165-445a-81b9-75870ba9f8e3/Steps/"],
                  ["予約の更新方法", "https://stonly.com/sl/b17c2e4c-bde8-4892-b668-ef2430711331/Steps/"],
                  ["予約のキャンセル", "https://stonly.com/sl/cc425264-8193-4e3c-b0af-4c68f6eca0a8/Steps/"],
                 ]
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
