module StaffsScheduleOutputer
  # 店舗全体のスタッフのスケジュールを取得

  # 勤務時間を取得
  def valid_shifts(staffs, term)
    result = staffs.map do |staff|
      a = staff.staff_shifts.without_rest_date.where(work_date: term)
        a.map do |shift|
          [shift&.work_start_time, shift&.work_end_time]
        end
    end
  end

  # 予定を取得
  def invalid_schedules(staffs, term)
    result = staffs.map do |staff|
      task_array = staff.tasks.where(start_time: term).map do |task|
        [task.start_time, task.end_time]
      end
      rest_array = staff.staff_shifts.where(work_date: term.first.to_date).map do |shift|
        shift.staff_rest_times.map do |rest|
          [rest.rest_start_time, rest.rest_end_time]
        end.flatten
      end
      (task_array + rest_array + public_staff_private(staff, term))
    end
    result
  end

  private
    
    def public_staff_private(staff, term)
      if staff.google_api_token
        array = SyncCalendarService.new(Task.new(), staff, staff.calendar).public_read_event(term).map do |event|
          [event[0].to_datetime, event[1].to_datetime]
        end
      else
        [[]]
      end
    end 



  module_function :valid_shifts, :invalid_schedules, :public_staff_private
end