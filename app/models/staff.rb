class Staff < ApplicationRecord
    belongs_to :calendar
    has_many :staff_shifts, dependent: :destroy
    has_many :tasks
    has_many :staff_regular_holidays
    accepts_nested_attributes_for :staff_regular_holidays

    after_create :create_staff_regular_holiday
    after_create :create_staff_shifts


    def create_staff_regular_holiday
        array = ["日", "月", "火", "水", "木", "金", "土"]
        start_time = Time.current.change(hour: self.calendar.start_time, min: 0)
        end_time = Time.current.change(hour: self.calendar.end_time, min: 0)
        array.each do |day|
            self.staff_regular_holidays.build(day: day, work_start_at: start_time, work_end_at: end_time).save
        end
    end

    def create_staff_shifts
        start_of_month = Date.current
        end_of_month = start_of_month.since(3.months).end_of_month
        [*start_of_month..end_of_month].each do |date|
            start_time = Time.parse("#{date}").since(10.hours).since(0.minutes)
            end_time = start_time.since(8.hours).since(0.minutes)
            self.staff_shifts.build(work_date: date, work_start_time: start_time, work_end_time: end_time).save
        end
    end
end
