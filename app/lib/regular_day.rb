class RegularDay
  attr_reader :calendar, :date

  def initialize(calendar, date)
    @calendar = calendar
    @date = date
  end

  def self.call(calendar, date)
    new(calendar, date).call
  end

  def call
    if regular_holidays.include?(w_day) || iregular_holidays.find_by(date: date)
      true
    else
      false
    end
  end

  private

  def regular_holidays
    @calendar.calendar_config.regular_holidays.where(holiday_flag: true).pluck(:day)
  end

  def iregular_holidays
    @calendar.calendar_config.iregular_holidays.where('date >= ?', Date.current)
  end

  def w_day
    %w[日 月 火 水 木 金 土][@date.wday]
  end
end
