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
                if self.is_rest?
                    if shift.staff_rest_times.find_by(is_default: true)
                        shift.staff_rest_times.find_by(is_default: true).update(rest_start_time: start_time.change(hour: self.rest_start_time.hour, min: self.rest_start_time.min),
                                                                                rest_end_time: end_time.change(hour: self.rest_end_time.hour, min: self.rest_end_time.min),
                                                                                is_default: true)
                    else
                        shift.staff_rest_times.build(rest_start_time: start_time.change(hour: self.rest_start_time.hour, min: self.rest_start_time.min),
                                                 rest_end_time: end_time.change(hour: self.rest_end_time.hour, min: self.rest_end_time.min),
                                                 is_default: true).save
                    end
                end
            end
        end
    end
end
