class User::Base < ApplicationController
  before_action :authenticate_user_staff!
  layout 'user'

  def calendar
    calendar_params = params[:calendar_id] || params[:id]
    @calendar = Calendar.find_by(public_uid: calendar_params)
    @q = Task.by_calendar(@calendar).ransack(params[:q])
  end

  def create_calendar_staffs_tasks(calendar)
    calendar.staffs.each do |staff|
      desplay_week_term = staff.calendar.display_week_term
      start_term = Date.current.beginning_of_month
      end_term = Date.current.weeks_since(desplay_week_term + 1).end_of_month
      last_shift = staff.staff_shifts.order(:work_date).last
      StaffShiftsCreator.call(start_term, end_term, staff)
    end
  end

  def authenticate_user_staff!
    unless current_user || current_staff
      redirect_to new_staff_session_url
    end
  end

end
