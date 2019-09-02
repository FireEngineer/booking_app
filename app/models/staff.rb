class Staff < ApplicationRecord
    belongs_to :calendar
    has_many :staff_shifts
    has_many :tasks
    has_many :staff_regular_holidays

    after_create :create_staff_regular_holiday


    def create_staff_regular_holiday
        array = ["日", "月", "火", "水", "木", "金", "土"]
        start_time = Time.current.change(hour: self.calendar.start_time, min: 0)
        end_time = Time.current.change(hour: self.calendar.end_time, min: 0)
        array.each do |day|
            self.staff_regular_holidays.build(day: day, work_start_at: start_time, work_end_at: end_time)
        end
    end
end
