module ApplicationHelper
  
  def time(date, time)
    puts time
    "#{date.year}-#{date.month}-#{date.day}T#{time.hour}:#{time.min}:00+09:00"
  end
  
  def time_display(time)
    "#{time.year}-#{time.month}-#{time.day} #{time.hour}時~#{time.hour + 1}時"
    # "#{time.year}-#{time.month}-#{time.day} #{time.hour}~#{time.hour.1.hours.since}"
  end

end
