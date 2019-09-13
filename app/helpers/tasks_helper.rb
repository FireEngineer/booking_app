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
end
