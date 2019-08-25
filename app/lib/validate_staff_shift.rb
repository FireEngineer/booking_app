class ValidateStaffShift

    attr_accessor :staff, :time

    def initialize(staff, time)
        @staff = staff
        @time = time
    end

    def self.call(staff, time)
        new(staff, time).call
    end

    def call
        shift = staff.staff_shifts.find_by(work_date: time.to_date)
        start_time = time.to_datetime
        end_time = time.to_datetime.since(set_interval_time.minutes)
        if shift.work_start_time < end_time && shift.work_end_time > start_time
            true
        else
            false
        end
    end

    private
        def set_interval_time
            # shift.staff.calendar.
            5
        end


end