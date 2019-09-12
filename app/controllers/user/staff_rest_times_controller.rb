class User::StaffRestTimesController < User::Base
    before_action :calendar

    def new
        @staff_rest_time = StaffRestTime.new()
    end

    def create
    end

    private
        def staff_rest_time_params
            params.require(:staff_rest_time).permit(:rest_start_time, :rest_end_time, :is_default, :staff_shift_id)
        end

end
