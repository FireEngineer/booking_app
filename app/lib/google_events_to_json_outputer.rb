module GoogleEventsToJsonOutputer

  def staff_shifts(staff)

    SyncCalendarService.new(Task.new(), staff, staff.calendar).read_event.map do |event|
      {
        title: 'google',
        start: I18n.l(event[0].to_time, format: :to_work_json),
        end: I18n.l(event[1].to_time, format: :to_work_json),
        backgroundColor: '#dc3545',
        editable: false,
        overlap: false
      }
    end
    rescue StandardError
      nil
end

module_function :staff_shifts

end