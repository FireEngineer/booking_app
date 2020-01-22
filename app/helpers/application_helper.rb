module ApplicationHelper
  def time(date, time)
    puts time
    "#{date.year}-#{date.month}-#{date.day}T#{time.hour}:#{time.min}:00+09:00"
  end

  def staff_name_helper(staff = nil)
    if staff
      staff.name
    else
      '指名なし'
    end
  end
end
