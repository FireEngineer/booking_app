module RegularHolidayDecorator
  def day_of_the_week
    case day
    when '月'
      '月曜日'
    when '火'
      '火曜日'
    when '水'
      '水曜日'
    when '木'
      '木曜日'
    when '金'
      '金曜日'
    when '土'
      '土曜日'
    when '日'
      '日曜日'
    end
  end
end
