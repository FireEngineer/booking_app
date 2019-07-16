module ApplicationHelper
  
  def time(date, time)
    date_time = date.since(time.hours)
    "#{date_time.year}-#{date_time.month}-#{date_time.day}T#{date_time.hour}:00:00+09:00"
  end
  
  def time_display(time)
    "#{time.year}-#{time.month}-#{time.day} #{time.hour}時~#{time.hour + 1}時"
    # "#{time.year}-#{time.month}-#{time.day} #{time.hour}~#{time.hour.1.hours.since}"
  end

end
