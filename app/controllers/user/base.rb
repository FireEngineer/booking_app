class User::Base < ApplicationController
  before_action :authenticate_user_staff!
  before_action :authenticate_current_user!
  before_action :initial_setting_complete?
  before_action :agreement_plan?

  layout 'user'

  def calendar
    calendar_params = params[:calendar_id] || params[:id]
    @calendar = Calendar.find_by(public_uid: calendar_params)
    @q = Task.only_valid.by_calendar(@calendar).ransack(params[:q])
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
    redirect_to new_staff_session_url unless current_user || current_staff
  end

  def authenticate_current_user!
    if current_staff
      flash[:danger] = '権限がありません'
      redirect_to user_calendar_dashboard_url(current_user, params[:calendar_id])
    end
  end

  def check_staff_course_exsist!
    if @calendar.staffs.none? && @calendar.task_courses.none?
      @cation = '1'
    elsif @calendar.staffs.none?
      @cation = '2'
    elsif @calendar.task_courses.none?
      @cation = '3'
    end
  end

  def initial_setting_complete?
    if current_user.calendars.none?
      flash[:danger] = '初期設定が完了していません。'
      redirect_to introductions_new_calendar
    elsif current_user.calendars.first.staffs.none?
      flash[:danger] = '初期設定が完了していません。'
      redirect_to introductions_new_staff_url
    elsif current_user.calendars.first.task_courses.none?
      flash[:danger] = '初期設定が完了していません。'
      redirect_to introductions_new_staff_url
    end
  end

  def agreement_plan?
    if current_user.order_plans.none?
      flash[:danger] = 'プランを選択してください。'
      redirect_to choice_plan_url
    end
  end
end
