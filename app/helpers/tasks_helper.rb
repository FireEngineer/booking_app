module TasksHelper
  
  # 予約ページの予約日時表示用ヘルパー
  def reservation_date(str_time)
    time = Time.zone.parse(str_time)
    l(time, format: :middle) + " 〜 " + l(time.change(hour: time.hour + 1), format: :very_short)
  end
  
  
  # topページのまるバツ判定
  def include_time?(events, str_time)
    time_s = Time.zone.parse(str_time)
    time_e = time_s.since(1.hours)
    count = 0
    events.each do |event|
      event_s = Time.zone.parse("#{event[0]}")
      event_e = Time.zone.parse("#{event[1]}")
      if event_s < time_e && time_s < event_e
        debugger
        count += 1
      end
    end
    if count >= 3
      false
    else
      true
    end
  end
end
