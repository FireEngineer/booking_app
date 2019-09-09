class Staff < ApplicationRecord
    acts_as_paranoid
    belongs_to :calendar
    has_many :staff_shifts, dependent: :destroy
    has_many :tasks
    has_many :staff_regular_holidays, dependent: :destroy
    accepts_nested_attributes_for :staff_regular_holidays

    after_create :create_staff_regular_holiday
    after_create :create_staff_shifts


    def create_staff_regular_holiday
        regular_holidays = get_regular_holidays
        get_regular_holidays.each do |holiday|
            self.staff_regular_holidays.build(day: holiday.day, work_start_at: holiday.business_start_at, work_end_at: holiday.business_end_at, regular_holiday_id: holiday.id).save
        end
    end

    def create_staff_shifts
        start_of_month = Date.current.beginning_of_month
        end_of_month = start_of_month.since(3.months).end_of_month
        regular_holidays = get_regular_holidays
        [*start_of_month..end_of_month].each do |date|
            day = ["日", "月", "火", "水", "木", "金", "土"][date.wday]
            staff_regular_holiday = self.staff_regular_holidays.find_by(day: day)
            start_time = Time.parse("#{date}").change(hour: (staff_regular_holiday.work_start_at - 9).hour, min: staff_regular_holiday.work_start_at.min)
            end_time = start_time.change(hour: (staff_regular_holiday.work_end_at - 9).hour, min: staff_regular_holiday.work_end_at.min)
            self.staff_shifts.build(work_date: date, work_start_time: start_time, work_end_time: end_time).save
        end
    end

    private
        def get_regular_holidays
            regular_holidays = self.calendar.calendar_config.regular_holidays
        end
end
