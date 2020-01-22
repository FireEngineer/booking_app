class User::SubTasksController < User::Base
  before_action :calendar
  skip_before_action :authenticate_current_user!

  def create
    task = Task.new(params_sub_task)
    task.attributes = { calendar_id: @calendar.id, is_sub: true, is_from_public: false }
    if task.save
      flash[:success] = '仮予約を作成しました'
      redirect_to user_calendar_dashboard_url(current_user, @calendar, staff_id: task.staff.id, task_id: task.id)
    else
      flash[:error] = task.errors.full_messages[0]
      redirect_to user_calendar_dashboard_url(current_user, @calendar, staff_id: task.staff.id, task_id: task.id)
    end
  end

  def edit
    @task = Task.only_valid.find(params[:id])
    @store_member = StoreMember.new
  end

  def update
    @task = Task.only_valid.find(params[:id])
    if @task.update(params_sub_task)
      flash[:success] = '仮予約を更新しました'
      redirect_to user_calendar_dashboard_url(current_user, @calendar, staff_id: @task.staff.id, task_id: @task.id)
    else
      flash[:error] = @task.errors.full_messages[0]
      redirect_to user_calendar_dashboard_url(current_user, @calendar, staff_id: @task.staff.id, task_id: @task.id)
    end
  end

  def update_by_drop
    @task = Task.only_valid.find_by(id: params[:id])
    if @task.update(start_time: params[:start_time], end_time: params[:end_time])
      render json: 'success'
    else
      render json: @task.errors.full_messages
    end
  end

  def update_to_task
    store_member = StoreMember.find_by(phone: params[:store_member]['phone']) || StoreMember.new(store_member_params)
    store_member.calendar = @calendar
    task_course = TaskCourse.find_by(id: task_params['task_course_id'])
    task = Task.only_valid.find(params[:id])
    task.attributes = task_params.merge(store_member_id: store_member.id,
                                        end_time: end_time(task.start_time.to_s, task_course),
                                        calendar_id: @calendar.id,
                                        is_sub: false)
    if store_member.save && task.save
      LineBot.new.push_message(task, store_member.line_user_id) if store_member.line_user_id
      NotificationMailer.send_confirm_to_user(task, @calendar.user, @calendar).deliver if store_member.email
      flash[:success] = '予約を作成しました'
      redirect_to user_calendar_dashboard_url(current_user, @calendar, staff_id: task.staff.id, task_id: task.id)
    else
      flash[:error] = task.errors.full_messages[0]
      redirect_to user_calendar_dashboard_url(current_user, @calendar, staff_id: task.staff.id, task_id: task.id)
    end
  end

  private

  def params_sub_task
    params.require(:task).permit(:name, :start_time, :end_time, :memo, :staff_id)
  end

  def store_member_params
    params.require(:store_member).permit(:name, :email, :phone, :gender, :age)
  end

  def task_params
    params.require(:task).permit(:start_time, :end_time, :staff_id, :task_course_id, :memo, :request)
  end
end
