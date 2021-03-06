class User::StaffRestTimesController < User::Base
  before_action :calendar
  skip_before_action :authenticate_current_user!

  def new
    @staff_rest_time = StaffRestTime.new
  end

  def create
    @staff = Staff.find(params[:staff_id])
    @shift = @staff.staff_shifts.find_by(work_date: params[:work_date])
    @rest = @shift.staff_rest_times.build(staff_rest_time_params)
    if @rest.save
      flash[:success] = '休憩を登録しました'
      redirect_to user_calendar_dashboard_url(current_user, @calendar, staff_id: @staff.id, rest_id: @rest.id)
    else
      flash[:danger] = '休憩を登録できませんでした'
      redirect_to user_calendar_dashboard_url(current_user, @calendar, staff_id: @staff.id, rest_id: @rest.id)
    end
  end

  def edit
    @staff_rest_time = StaffRestTime.find(params[:id])
  end

  def update
    @staff_rest_time = StaffRestTime.find(params[:id])
    staff = @staff_rest_time.staff_shift.staff
    if @staff_rest_time.update(staff_rest_time_params)
      flash[:success] = '休憩を更新しました'
      redirect_to user_calendar_dashboard_url(current_user, @calendar, staff_id: staff.id, rest_id: @staff_rest_time.id)
    else
      if @staff_rest_time.errors
        @staff_rest_time.errors.full_messages.each do |msg|
          flash[:danger] = msg
        end
      else
        flash[:danger] = '休憩を更新できませんでした'
      end
      redirect_to user_calendar_dashboard_url(current_user, @calendar, staff_id: staff.id, rest_id: @staff_rest_time.id)
    end
  end

  def update_by_drop
    @staff_rest_time = StaffRestTime.find(params[:id])
    if @staff_rest_time.update(rest_start_time: params[:rest_start_time], rest_end_time: params[:rest_end_time])
      render json: 'success'
    else
      render json: @staff_rest_time.errors.full_messages.first
    end
  end

  def destroy
    @staff_rest_time = StaffRestTime.find(params[:id])
    staff = @staff_rest_time.staff_shift.staff
    @staff_rest_time.destroy
    flash[:cation] = '休憩を削除しました。'
    redirect_to user_calendar_dashboard_url(current_user, @calendar, staff_id: staff.id)
  end

  private

  def staff_rest_time_params
    params.require(:staff_rest_time).permit(:rest_start_time, :rest_end_time, :is_default, :staff_shift_id)
  end
end
