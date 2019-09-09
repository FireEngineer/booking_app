class StaffRegularHoliday < ApplicationRecord
    belongs_to :staff
    belongs_to :regular_holiday

    after_update :update_staff_shifts

    def update_staff_shifts
        self.staff.staff_shifts.where("work_date >= ?", Date.current).each do |shift|
            start_time = shift.work_start_time.change(hour: (self.work_start_at).hour, min: self.work_start_at.min)
            end_time = start_time.change(hour: (self.work_end_at).hour, min: self.work_end_at.min)
            if %w(日 月 火 水 木 金 土)[shift.work_date.wday] == self.day
                shift.update(is_holiday: self.is_holiday, work_start_time: start_time, work_end_time: end_time)
            end
        end
    end
end
