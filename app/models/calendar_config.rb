class CalendarConfig < ApplicationRecord

    belongs_to :calendar
    has_many :regular_holidays
    
end
