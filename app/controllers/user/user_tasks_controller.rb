class User::UserTasksController < User::Base
  before_action :calendar

  def index
    if params[:except_past_task]
      @q = Task.by_calendar(@calendar).expect_past.ransack(params[:q])
    else
      @q = Task.by_calendar(@calendar).ransack(params[:q])
    end
    @q.sorts = 'start_time desc'
    @tasks = @q.result(distinct: true).page(params[:page]).per(10)
  end

  def new
    @calendar = Calendar.find_by(public_uid: params[:calendar_id])
    if params[:store_member_id]
      @store_member = StoreMember.find(params[:store_member_id])
    else
      @store_member = StoreMember.new
    end
    @task = Task.new(start_time: params[:start_time])
    # スタッフの休憩作成用
    @staff_rest_time = StaffRestTime.new(rest_start_time: params[:start_time], rest_end_time: params[:start_time].to_time.since(1.hours))
  end

  def create
    @calendar = Calendar.find_by(public_uid: params[:calendar_id])
    # 会員がいるかどうか
    @store_member = StoreMember.find_by(phone: params[:store_member]['phone']) || StoreMember.new(store_member_params)
    @store_member.calendar = @calendar
    task = @store_member.tasks.build(task_params)
    task_course = TaskCourse.find_by(id: task_params['task_course_id'])
    task.end_time = end_time(task.start_time.to_s, task_course)
    task.calendar = @calendar
    if @store_member.save
      flash[:success] = '予約を作成しました'
      redirect_to user_calendar_dashboard_url(current_user, @calendar, staff_id: task.staff.id, task_id: task.id)
    else
      flash[:error] = @store_member.errors.full_messages[0]
      redirect_to user_calendar_dashboard_url(current_user, @calendar, staff_id: task.staff.id, task_id: task.id)
    end
  end

  def show
    @task = Task.find(params[:id])
  end

  def update
    @task = Task.find(params[:id])
    @task.attributes = task_params
    task_course = @task.task_course
    if @task.save
      flash[:success] = '予約を更新しました'
      redirect_to user_calendar_dashboard_url(current_user, @calendar, staff_id: @task.staff.id, task_id: @task.id)
    else
      flash[:success] = '予約の更新ができませんでした。'
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

  def destroy
    @task = Task.find_by(id: params[:id])
    if @task.destroy
      respond_to do |format|
        format.html { redirect_to user_calendar_dashboard_url(current_user, @calendar, staff_id: @task.staff.id), notice: '予約をキャンセルしました。' }
        format.json { head :no_content }
        format.js { render :destroy }
      end
    else
      flash[:warnnig] = '予約をキャンセルできませんでした。'
      redirect_to user_calendar_user_tasks_url(params[:user_id])
    end
  end

  private

  def store_member_params
    params.require(:store_member).permit(:name, :email, :phone, :gender, :age)
  end

  def task_params
    params.require(:task).permit(:start_time, :end_time, :staff_id, :task_course_id, :memo)
  end
end
