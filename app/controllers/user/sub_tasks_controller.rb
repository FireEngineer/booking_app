class User::SubTasksController < User::Base
  before_action :calendar

  def create
    @task = Task.new(params_sub_task)
    @task.calendar = @calendar
    if @task.save
      flash[:success] = '仮予約を作成しました'
      redirect_to user_calendar_dashboard_url(current_user, @calendar, staff_id: task.staff.id, task_id: task.id)
    else
      flash[:error] = @store_member.errors.full_messages[0]
      redirect_to user_calendar_dashboard_url(current_user, @calendar, staff_id: task.staff.id, task_id: task.id)
    end
  end

  private
    def params_sub_task
      params.require(:task).permit(:name, :start_time, :end_time, :memo)
    end
end
