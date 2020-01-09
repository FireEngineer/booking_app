module StaffTaskToJsonOutputer

    def staff_shifts(staff)
        test = staff.staff_shifts.where(work_date: [*Date.current..Date.current.since(calendar_display_term.months).end_of_month]).map do |shift|
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
          []
    end

    def staff_rests(staff)
        staff.staff_shifts.where(work_date: [*Date.current..Date.current.since(calendar_display_term.months).end_of_month]).map do |shift|
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
          []
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
          []
    end

    def public_staff_shifts(staffs, term)
      staffs.map do |staff|
        array = staff.staff_shifts.without_rest_date.where(work_date: term).map do |shift|
          [shift.work_start_time, shift.work_end_time]
        end.flatten
      end
    end

    def public_staff_tasks(staffs, term)
      staffs.map do |staff|
        array = staff.tasks.where(start_time: term).map do |task|
          [task.start_time, task.end_time]
        end.flatten
      end
    end

    def public_staff_rests(staffs, term)
      staffs.map do |staff|
        array = staff.staff_shifts.where(work_date: term.first.to_date).map do |shift|
            shift.staff_rest_times.map do |rest|
              [rest.rest_start_time, rest.rest_end_time]
            end
          end.flatten
        rescue StandardError
          nil
      end
    end

    private
      def calendar_display_term
        ENV['CALENDAR_DISPLAY_TERM'].to_i
      end

    module_function :staff_shifts, :staff_rests, :staff_tasks, :calendar_display_term, :public_staff_shifts, :public_staff_tasks, :public_staff_rests

end