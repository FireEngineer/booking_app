class User::StaffRestTimesController < User::Base
    before_action :calendar

    def new
        @staff_rest_time = StaffRestTime.new()
    end

    def create
        @staff = Staff.find(params[:staff_id])
        @shift = @staff.staff_shifts.find_by(work_date: params[:work_date])
        @rest = @shift.staff_rest_times.build(staff_rest_time_params)
        if @rest.save
            flash[:success] = "休憩を登録しました"
            redirect_to user_calendar_dashboard_url(current_user, @calendar)
        else
            flash[:success] = "休憩を登録しました"
            redirect_to user_calendar_dashboard_url(current_user, @calendar)
        end
    end

    private
        def staff_rest_time_params
            params.require(:staff_rest_time).permit(:rest_start_time, :rest_end_time, :is_default, :staff_shift_id)
        end

end
