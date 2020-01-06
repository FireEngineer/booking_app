class User::Base < ApplicationController
  before_action :authenticate_user_staff!
  before_action :authenticate_current_user!

  layout 'user'

  def calendar
    calendar_params = params[:calendar_id] || params[:id]
    @calendar = Calendar.find_by(public_uid: calendar_params)
    @q = Task.by_calendar(@calendar).ransack(params[:q])
  end

  def create_calendar_staffs_tasks(calendar)
    calendar.staffs.each do |staff|
      desplay_month_term = ENV['CALENDAR_DISPLAY_TERM'].to_i
      start_term = Date.current.beginning_of_month
      end_term = Date.current.weeks_since(desplay_month_term + 1).end_of_month
      last_shift = staff.staff_shifts.order(:work_date).last
      StaffShiftsCreator.call(start_term, end_term, staff)
    end
  end

  def authenticate_user_staff!
    unless current_user || current_staff
      redirect_to new_staff_session_url
    end
  end

  def authenticate_current_user!
    if current_staff
      flash[:danger] = "権限がありません"
      redirect_to user_calendar_dashboard_url(current_user, params[:calendar_id])
    end
  end

  def check_staff_course_exsist!
    if !@calendar.staffs.any? && !@calendar.task_courses.any?
      @cation = "1"
    elsif !@calendar.staffs.any?
      @cation = "2"
    elsif !@calendar.task_courses.any?
      @cation = "3"
    end

  end

  def agreement_plan?
    if !current_user.calendars.any?
      flash[:danger] = "初期設定が完了していません。"
      redirect_to introductions_new_calendar
    elsif !current_user.calendars.first.staffs.any?
      flash[:danger] = "初期設定が完了していません。"
      redirect_to introductions_new_staff_url
    elsif current_user.calendars.first.task_courses.any?
      flash[:danger] = "初期設定が完了していません。"
      redirect_to introductions_new_staff_url
    end
  end

end
