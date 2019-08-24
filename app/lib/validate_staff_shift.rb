class ValidateStaffShift

    attr_accessor :shifts, :time

    def initialize(shifts, time)
        @shifts = shifts
        @time = time
    end

    def self.call(shifts, time)
        new(shifts, time).call
    end

    def call
        time_start = Time.zone.parse(time)
        time_end = Time.zone.parse(time).since(set_interval_time.minutes)
        shifts.each do |shift|
            shift_start = shift.work_start_time
            shift_end = shift.work_end_time
            if shift_start < time_end && time_start < shift_end
                return false
            end

        end
        true
    end

    private
        def set_interval_time
            # shift.staff.calendar.
            5
        end


end