class User::TopController < User::Base
    before_action :calendar

  def dashboard
    @user = current_user
    @staffs = @calendar.staffs
    @staff = Staff.find_by(id: params[:staff_id])
    staff_shifts = staff_shifts(@staff)
    staff_tasks = staff_tasks(@staff, params[:task_id])
    @events = (staff_shifts + staff_tasks)&.to_json rescue calendar_tasks(@calendar).to_json
    if params[:task_id]
      task_date = Task.find_by(id: params[:task_id]).start_time.to_date
      @current_date = l(task_date, format: :to_json)
    else
      @current_date = l(Date.current, format: :to_json)
    end
  end

  private
    # スタッフのシフトのJSON
    def staff_shifts(staff)
      staff.staff_shifts.map do |shift|
        { 
          start: l(shift.work_start_time, format: :to_work_json),
          end: l(shift.work_end_time, format: :to_work_json),
          rendering: 'background' ,
        }
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
end
