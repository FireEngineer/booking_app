class RegularHoliday < ApplicationRecord
    belongs_to :calendar_config
    has_many :staff_regular_holidays

    after_update :update_staff_regular_holiday

    def update_staff_regular_holiday
        self.staff_regular_holidays.where(is_holiday: false).each do |holiday|
            holiday.update(is_holiday: self.holiday_flag,
                           work_start_at: self.business_start_at,
                           work_end_at: self.business_end_at,
                           )
        end
    end
end
