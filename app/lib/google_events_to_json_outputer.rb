module GoogleEventsToJsonOutputer
  # スタッフのgoogleカレンダー予定

  # googleカレンダーのプライベートの予定を取得
  def staff_private(staff)
    SyncCalendarService.new(Task.new(), staff, staff.calendar).read_event.map do |event|
      unless Task.find_by(google_event_id: event[2])
        {
          title: 'google',
          start: I18n.l(event[0].to_time, format: :to_work_json),
          end: I18n.l(event[1].to_time, format: :to_work_json),
          backgroundColor: '#dc3545',
          editable: false,
          overlap: false
        }
      end
    end.compact
    rescue StandardError
      []
  end

  def public_staff_private(staffs, term)
    staffs.map do |staff|
      if staff.google_api_token
        array = SyncCalendarService.new(Task.new(), staff, staff.calendar).public_read_event(term).map do |event|
          [event[0].to_time, event[1].to_time]
        end
        if array.nil?
          []
        else
          array
        end
      end
    end
  end

  module_function :staff_private, :public_staff_private

end