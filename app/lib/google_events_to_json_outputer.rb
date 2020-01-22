module GoogleEventsToJsonOutputer
  # スタッフのgoogleカレンダー予定

  # googleカレンダーのプライベートの予定を取得
  def staff_private(staff)
    SyncCalendarService.new(Task.new, staff, staff.calendar).read_event.map do |event|
      next if Task.only_valid.find_by(google_event_id: event[2])

      {
        title: 'google',
        start: I18n.l(event[0].to_time, format: :to_work_json),
        end: I18n.l(event[1].to_time, format: :to_work_json),
        backgroundColor: '#dc3545',
        editable: false,
        overlap: false
      }
    end.compact
  rescue StandardError
    []
  end

  module_function :staff_private
end
