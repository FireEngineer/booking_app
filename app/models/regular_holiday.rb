class RegularHoliday < ApplicationRecord
  belongs_to :calendar_config
  has_many :staff_regular_holidays

  # after_update :update_staff_regular_holiday

  # def update_staff_regular_holiday
  #   staff_regular_holidays.each do |holiday|
  #     holiday.update(is_holiday: holiday_flag,
  #                    work_start_at: business_start_at,
  #                    work_end_at: business_end_at,
  #                    rest_start_time: rest_start_time,
  #                    rest_end_time: rest_end_time,
  #                    is_rest: is_rest,
  #                   )
  #   end
  # end
end
