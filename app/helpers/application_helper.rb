module ApplicationHelper
  
  def time(date, time)
    date_time = date.since(time.hours)
    "#{date_time.year}-#{date_time.month}-#{date_time.day}T#{date_time.hour}:00:00+09:00"
  end
  
end
