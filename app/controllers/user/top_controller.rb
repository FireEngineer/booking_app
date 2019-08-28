class User::TopController < User::Base

    before_action :calendar

  def dashboard
    @user = current_user
    @staffs = @calendar.staffs
    @staff = Staff.find_by(id: params[:staff_id]) || @calendar.staffs.first
    staff_shifts = staff_shifts(@staff)
    staff_tasks = staff_tasks(@staff)
    @events = (staff_shifts + staff_tasks)&.to_json
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
      def staff_tasks(staff)
        staff.tasks.map do |task|
          { 
            title: "#{task.store_member.name}:#{task.task_course.title}",
            start: l(task.start_time, format: :to_work_json),
            end: l(task.end_time, format: :to_work_json),
            id: task.id,
          }
        end rescue nil
      end

end
