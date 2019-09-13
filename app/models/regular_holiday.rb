class RegularHoliday < ApplicationRecord
  belongs_to :calendar_config
  has_many :staff_regular_holidays

  after_update :update_staff_regular_holiday

  def update_staff_regular_holiday
    staff_regular_holidays.where(is_holiday: false).each do |holiday|
      holiday.update(is_holiday: holiday_flag,
                     work_start_at: business_start_at,
                     work_end_at: business_end_at)
    end
  end
end
