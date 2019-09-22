class User::SubTasksController < User::Base
  before_action :calendar

  def create
    task = Task.new(params_sub_task)
    task.calendar = @calendar
    task.is_sub = true
    if task.save
      flash[:success] = '仮予約を作成しました'
      redirect_to user_calendar_dashboard_url(current_user, @calendar, staff_id: task.staff.id, task_id: task.id)
    else
      flash[:error] = task.errors.full_messages[0]
      redirect_to user_calendar_dashboard_url(current_user, @calendar, staff_id: task.staff.id, task_id: task.id)
    end
  end

  def edit
    @task = Task.find(params[:id])
  end

  def update
    @task = Task.find(params[:id])
    if @task.update(params_sub_task)
      flash[:success] = '仮予約を更新しました'
      redirect_to user_calendar_dashboard_url(current_user, @calendar, staff_id: @task.staff.id, task_id: @task.id)
    else
      flash[:error] = @task.errors.full_messages[0]
      redirect_to user_calendar_dashboard_url(current_user, @calendar, staff_id: @task.staff.id, task_id: @task.id)
    end
  end

  def update_by_drop
    @task = Task.find_by(id: params[:id])
    if @task.update(start_time: params[:start_time], end_time: params[:end_time])
      render json: 'success'
    else
      render json: @task.errors.full_messages
    end
  end

  private
    def params_sub_task
      params.require(:task).permit(:name, :start_time, :end_time, :memo, :staff_id)
    end
end
