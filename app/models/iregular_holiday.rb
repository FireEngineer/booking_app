class IregularHoliday < ApplicationRecord
    belongs_to :calendar_config

    validate :check_only_date_with_calendare
    validate :check_regular_holiday

    def check_only_date_with_calendare
        if self.calendar_config.iregular_holidays.find_by(date: self.date)
            errors.add(:date, "休日が重複しています") # エラーメッセージ
        end
    end

    def check_regular_holiday
        day = ["日", "月", "火", "水", "木", "金", "土"][self.date.wday]
        if self.calendar_config.regular_holidays.find_by(day: day)
            errors.add(:date, "この日は定休日です") # エラーメッセージ
        end
    end
end
