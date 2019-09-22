module StaffTaskToJsonOutputer

    def staff_shifts(staff)
        test = staff.staff_shifts.where(work_date: [*Date.current..Date.current.since(staff.calendar.display_week_term.months).end_of_month]).map do |shift|
            day = %w[日 月 火 水 木 金 土][shift.work_date.wday]
            if staff.calendar.calendar_config.regular_holidays.where(holiday_flag: true).find_by(day: day)
              {
                title: 'お店定休日',
                start: I18n.l(shift.work_start_time.beginning_of_day, format: :to_work_json),
                end: I18n.l(shift.work_end_time.end_of_day, format: :to_work_json),
                backgroundColor: '#afabab',
                editable: false,
                overlap: false
              }
            elsif staff.calendar.calendar_config.iregular_holidays.find_by(date: shift.work_date)
              {
                title: 'お店臨時休日',
                start: I18n.l(shift.work_start_time.beginning_of_day, format: :to_work_json),
                end: I18n.l(shift.work_end_time.end_of_day, format: :to_work_json),
                backgroundColor: '#afabab',
                editable: false,
                overlap: false
              }
            elsif staff.staff_regular_holidays.where(is_holiday: true).find_by(day: day)
              {
                title: 'スタッフ休日',
                start: I18n.l(shift.work_start_time.beginning_of_day, format: :to_work_json),
                end: I18n.l(shift.work_end_time.end_of_day, format: :to_work_json),
                backgroundColor: '#afabab',
                editable: false,
                overlap: false
              }
            else
              {
                start: I18n.l(shift.work_start_time, format: :to_work_json),
                end: I18n.l(shift.work_end_time, format: :to_work_json),
                rendering: 'background'
              }
            end
          end
        rescue StandardError
          nil
    end

    def staff_rests(staff)
        staff.staff_shifts.where(work_date: [*Date.current..Date.current.since(staff.calendar.display_week_term.months).end_of_month]).map do |shift|
            shift.staff_rest_times.map do |rest|
              {
                title: 'スタッフ休憩',
                start: I18n.l(rest.rest_start_time, format: :to_work_json),
                end: I18n.l(rest.rest_end_time, format: :to_work_json),
                backgroundColor: '#afabab',
                classNames: ['staff_rest', rest.id]
              }
            end
          end.flatten
        rescue StandardError
          nil
    end

    def staff_tasks(staff, search_id)
        staff.tasks.map do |task|
            if task.is_sub?
              {
                  title: "仮予約",
                  start: I18n.l(task.start_time, format: :to_work_json),
                  end: I18n.l(task.end_time, format: :to_work_json),
                  id: task.id,
                  classNames: 'sub_task',
                  backgroundColor: '#FF9800'
              }
            elsif search_id && task.id == search_id.to_i
              {
                title: "#{task.store_member.name}様:#{task.task_course.title}:担当者#{staff.name}",
                start: I18n.l(task.start_time, format: :to_work_json),
                end: I18n.l(task.end_time, format: :to_work_json),
                id: task.id,
                color: 'purple',
                classNames: 'staff_task',
              }
            elsif task.end_time < Time.current
              {
                title: "#{task.store_member.name}様:#{task.task_course.title}:担当者#{staff.name}",
                start: I18n.l(task.start_time, format: :to_work_json),
                end: I18n.l(task.end_time, format: :to_work_json),
                id: task.id,
                classNames: 'staff_task',
                backgroundColor: 'slategrey'
              }
            else
              {
                title: "#{task.store_member.name}様:#{task.task_course.title}:担当者#{staff.name}",
                start: I18n.l(task.start_time, format: :to_work_json),
                end: I18n.l(task.end_time, format: :to_work_json),
                id: task.id,
                classNames: 'staff_task',
              }
            end
          end
        rescue StandardError
          nil
    end

    module_function :staff_shifts, :staff_rests, :staff_tasks

end