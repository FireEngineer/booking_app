class RegularHoliday < ApplicationRecord
    belongs_to :calendar_config
    has_many :staff_regular_holidays
end
