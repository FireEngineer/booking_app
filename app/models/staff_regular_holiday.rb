class StaffRegularHoliday < ApplicationRecord
    belongs_to :staff
    belongs_to :regular_holiday

    after_update :update_staff_shifts

    def update_staff_shifts
        self.staff.staff_shifts.where("work_date >= ?", Date.current).each do |shift|
            if %w(日 月 火 水 木 金 土)[shift.work_date.wday] == self.day
                shift.update(is_holiday: self.is_holiday, work_start_time: self.work_start_at, work_end_time: self.work_end_at)
            end
        end
    end
end
