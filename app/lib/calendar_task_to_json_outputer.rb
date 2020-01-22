module CalendarTaskToJsonOutputer
  def calendar_tasks(calendar)
    calendar.tasks.map do |task|
      if task.is_sub?
        {
          title: '仮予約',
          start: I18n.l(task.start_time, format: :to_work_json),
          end: I18n.l(task.end_time, format: :to_work_json),
          id: task.id,
          classNames: 'sub_task',
          backgroundColor: '#FF9800'
        }
      elsif task.end_time < Time.current
        {
          title: "#{task.store_member.name}様:#{task.task_course.title}:担当者#{task.staff.name}",
          start: I18n.l(task.start_time, format: :to_work_json),
          end: I18n.l(task.end_time, format: :to_work_json),
          id: task.id,
          classNames: 'staff_task',
          backgroundColor: 'slategrey'
        }
      else
        {
          title: "#{task.store_member.name}様:#{task.task_course.title}:担当者#{task.staff.name}",
          start: I18n.l(task.start_time, format: :to_work_json),
          end: I18n.l(task.end_time, format: :to_work_json),
          id: task.id,
          classNames: 'staff_task'
        }
      end
    end
  end

  def calendar_holidays(calendar)
    term = ENV['CALENDAR_DISPLAY_TERM'].to_i # calendar.display_week_term.to_i
    [*Date.current.beginning_of_month..Date.current.since(term.months).end_of_month].map do |date|
      day = %w[日 月 火 水 木 金 土][date.wday]
      if calendar.calendar_config.regular_holidays.where(holiday_flag: true).find_by(day: day)
        {
          title: 'お店定休日',
          start: I18n.l(date.beginning_of_day, format: :to_work_json),
          end: I18n.l(date.end_of_day, format: :to_work_json),
          backgroundColor: '#afabab',
          editable: false,
          overlap: false
        }
      elsif calendar.calendar_config.iregular_holidays.find_by(date: date)
        {
          title: 'お店臨時休日',
          start: I18n.l(date.beginning_of_day, format: :to_work_json),
          end: I18n.l(date.end_of_day, format: :to_work_json),
          backgroundColor: '#afabab',
          editable: false,
          overlap: false
        }
      else
        {}
      end
    end
  end

  module_function :calendar_tasks, :calendar_holidays
end
