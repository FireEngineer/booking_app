class CalendarConfig < ApplicationRecord

    belongs_to :calendar
    has_many :regular_holidays
    accepts_nested_attributes_for :regular_holidays, allow_destroy: true


end
