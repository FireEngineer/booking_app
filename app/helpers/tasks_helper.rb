module TasksHelper
  # 予約ページの予約日時表示用ヘルパー
  def reservation_date(task)
    l(task.start_time, format: :middle) + ' 〜 ' + l(task.end_time, format: :very_short)
  end

  # topページのまるバツ判定
  def include_time?(events, str_time)
    time_s = Time.zone.parse(str_time)
    time_e = time_s.since(1.hours)
    count = 0
    events.each do |event|
      event_s = Time.zone.parse((event[0]).to_s)
      event_e = Time.zone.parse((event[1]).to_s)
      count += 1 if event_s < time_e && time_s < event_e
    end
    count < 3
  end

  # 勤務時間内かどうか
  def include_shift?(terms, start_time, end_time)
    terms.each do |term|
      if term.first <= start_time && end_time <= term.last
        return "ok"
      end
    rescue
    end
    return "not"
  end

  # 予約が入れられる時間かどうか
  def invalid_time?(not_term, start_time, end_time)
    not_term.each do |term|
      if start_time < term.last && term.first < end_time
        return "not"
      end
    rescue
      
    end
    return "ok"
  end

  def not_term(staffs, term)
    StaffTaskToJsonOutputer.public_staff_tasks(staffs, term) +
    StaffTaskToJsonOutputer.public_staff_rests(staffs, term) +
    GoogleEventsToJsonOutputer.public_staff_private(staffs, term)
  end

end
