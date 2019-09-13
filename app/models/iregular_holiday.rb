class IregularHoliday < ApplicationRecord
  belongs_to :calendar_config

  validate :check_only_date_with_calendare
  validate :check_regular_holiday
  validate :check_task

  def check_only_date_with_calendare
    if calendar_config.iregular_holidays.find_by(date: date)
      errors.add(:date, '休日が重複しています') # エラーメッセージ
    end
  end

  def check_regular_holiday
    day = %w[日 月 火 水 木 金 土][date.wday]
    if calendar_config.regular_holidays.where(holiday_flag: true).find_by(day: day)
      errors.add(:date, 'この日は定休日です') # エラーメッセージ
    end
  end

  def check_task
    date_time = date.to_time
    if calendar_config.calendar.tasks.where('start_time < ? && start_time > ?', date_time.end_of_day, date_time.beginning_of_day).any?
      errors.add(:date, 'この日は予約が入っているので、休日にできません。') # エラーメッセージ
    end
  end
end
