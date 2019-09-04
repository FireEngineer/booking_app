class User::TopController < User::Base
    before_action :calendar

  def dashboard
    @user = current_user
    @staffs = @calendar.staffs
    @staff = Staff.find_by(id: params[:staff_id])
    staff_shifts = staff_shifts(@staff)
    staff_tasks = staff_tasks(@staff, params[:task_id])
    @events = (staff_shifts + staff_tasks)&.to_json rescue (calendar_tasks(@calendar)+calendar_holidays(@calendar)).to_json
    if params[:task_id]
      task_date = Task.find_by(id: params[:task_id]).start_time.to_date
      @current_date = l(task_date, format: :to_json)
    else
      @current_date = l(Date.current, format: :to_json)
    end
    @data_calendar = date_range(@calendar)
  end

  private
    # スタッフのシフトのJSON
    def staff_shifts(staff)
      staff.staff_shifts.where(work_date: [*Date.current..Date.current.since(staff.calendar.display_week_term.months).end_of_month]).map do |shift|
        day = ["日", "月", "火", "水", "木", "金", "土"][shift.work_date.wday]
        if staff.calendar.calendar_config.regular_holidays.where(holiday_flag: true).find_by(day: day)
          { 
            title: "お店定休日",
            start: l(shift.work_start_time.beginning_of_day, format: :to_work_json),
            end: l(shift.work_end_time.end_of_day, format: :to_work_json),
            backgroundColor: '#afabab',
            editable: false,
            overlap: false
          }
        elsif staff.calendar.calendar_config.iregular_holidays.find_by(date: shift.work_date)
          { 
            title: "お店臨時休日",
            start: l(shift.work_start_time.beginning_of_day, format: :to_work_json),
            end: l(shift.work_end_time.end_of_day, format: :to_work_json),
            backgroundColor: '#afabab',
            editable: false,
            overlap: false
          }
        elsif staff.staff_regular_holidays.where(is_holiday: true).find_by(day: day)
          { 
            title: "スタッフ休日",
            start: l(shift.work_start_time.beginning_of_day, format: :to_work_json),
            end: l(shift.work_end_time.end_of_day, format: :to_work_json),
            backgroundColor: '#afabab',
            editable: false,
            overlap: false
          }
        else
          { 
            start: l(shift.work_start_time, format: :to_work_json),
            end: l(shift.work_end_time, format: :to_work_json),
            rendering: 'background' ,
          }
        end
      end rescue nil
    end
      
      # スタッフのタスクのJSON
      def staff_tasks(staff, search_id)
        staff.tasks.map do |task|
          if search_id && task.id == search_id.to_i
            { 
              title: "#{task.store_member.name}様:#{task.task_course.title}:担当者#{staff.name}",
              start: l(task.start_time, format: :to_work_json),
              end: l(task.end_time, format: :to_work_json),
              id: task.id,
              color: 'purple',
            }
          else
            { 
              title: "#{task.store_member.name}様:#{task.task_course.title}:担当者#{staff.name}",
              start: l(task.start_time, format: :to_work_json),
              end: l(task.end_time, format: :to_work_json),
              id: task.id,
            }
          end
        end rescue nil
      end
      
      def calendar_tasks(calendar)
        calendar.tasks.map do |task|
          { 
            title: "#{task.store_member.name}様:#{task.task_course.title}:担当者#{task.staff.name}",
            start: l(task.start_time, format: :to_work_json),
            end: l(task.end_time, format: :to_work_json),
            id: task.id,
          }
        end
      end

      def calendar_holidays(calendar)
        term = calendar.display_week_term.to_i
        [*Date.current.beginning_of_month..Date.current.since(term.months).end_of_month].map do |date|
          day = ["日", "月", "火", "水", "木", "金", "土"][date.wday]
          if calendar.calendar_config.regular_holidays.where(holiday_flag: true).find_by(day: day)
            { 
              title: "お店定休日",
              start: l(date.beginning_of_day, format: :to_work_json),
              end: l(date.end_of_day, format: :to_work_json),
              backgroundColor: '#afabab',
              editable: false,
              overlap: false
            }
          elsif calendar.calendar_config.iregular_holidays.find_by(date: date)
            { 
              title: "お店臨時休日",
              start: l(date.beginning_of_day, format: :to_work_json),
              end: l(date.end_of_day, format: :to_work_json),
              backgroundColor: '#afabab',
              editable: false,
              overlap: false
            }
          else
            {}
          end
        end

      end

      def date_range(calendar)
        term = calendar.display_week_term.to_i
        hash = {
          "start_date": Date.current.beginning_of_month,
          "end_date": Date.current.since(term.months).end_of_month,
         }.to_json
      end
end
