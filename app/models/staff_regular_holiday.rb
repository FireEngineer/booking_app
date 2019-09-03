class StaffRegularHoliday < ApplicationRecord
    belongs_to :staff
    belongs_to :regular_holiday
end
