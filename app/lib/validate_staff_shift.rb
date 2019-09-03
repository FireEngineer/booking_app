class ValidateStaffShift

    attr_accessor :staff, :time, :task_course

    def initialize(staff, time, task_course)
        @staff = staff
        @time = time
        @task_course = task_course
    end

    def self.call(staff, time, task_course)
        new(staff, time, task_course).call
    end

    def call
        shift = staff.staff_shifts.find_by(work_date: time.to_date)
        day = ["日", "月", "火", "水", "木", "金", "土"][shift.work_date.wday]
        start_time = time.to_datetime
        end_time = time.to_datetime.since(task_course.course_time.minutes)
        if shift.work_start_time <= start_time && shift.work_end_time >= end_time && !staff.staff_regular_holidays.where(is_holiday: true).find_by(day: day)
            true
        else
            false
        end
    end


end