class User::UserTasksController < User::Base
  before_action :calendar
  skip_before_action :authenticate_current_user!

  def index
    @q = if params[:except_past_task]
           Task.only_valid.by_calendar(@calendar).expect_past.ransack(params[:q])
         else
           Task.only_valid.by_calendar(@calendar).ransack(params[:q])
         end
    @q.sorts = 'start_time desc'
    @tasks = @q.result(distinct: true).page(params[:page]).per(10)
  end

  def new
    @calendar = Calendar.find_by(public_uid: params[:calendar_id])
    @store_member = if params[:store_member_id]
                      StoreMember.find(params[:store_member_id])
                    else
                      StoreMember.new
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
    task.attributes = { end_time: end_time(task.start_time.to_s, task_course),
                        calendar_id: @calendar.id,
                        is_from_public: false }

    ActiveRecord::Base.transaction do
      @store_member.save!
      sync_google_calendar_create(task)
      LineBot.new.push_message(task, @store_member.line_user_id) if @store_member.line_user_id
      NotificationMailer.send_confirm_to_user(task, @calendar.user, @calendar).deliver if @store_member.email
    end
    flash[:success] = '予約を作成しました'
    redirect_to user_calendar_dashboard_url(current_user, @calendar, staff_id: task.staff.id, task_id: task.id)
  rescue StandardError
    # sync_google_calendar_create(task)
    flash[:error] = @store_member.errors.full_messages[0]
    redirect_to user_calendar_dashboard_url(current_user, @calendar, staff_id: task.staff.id, task_id: task.id)
  end

  def show
    @task = Task.only_valid.find(params[:id])
  end

  def update
    @task = Task.only_valid.find(params[:id])
    @task.attributes = task_params
    task_course = @task.task_course
    ActiveRecord::Base.transaction do
      @task.save!
      sync_google_calendar_update(@task)
      if params[:is_send_notice_to_member] == '1' && @task.start_time > Time.current
        LineBot.new.push_message_with_edit_task(@task, @task.store_member.line_user_id) if @task.store_member.line_user_id
        NotificationMailer.send_edit_task_to_user(@task, @calendar.user, @calendar).deliver if @task.store_member.email
      end
    end
    flash[:success] = '予約を更新しました'
    redirect_to user_calendar_dashboard_url(current_user, @calendar, staff_id: @task.staff.id, task_id: @task.id)
  rescue StandardError
    sync_google_calendar_update(@task.reload)
    flash[:success] = '予約の更新ができませんでした。'
    redirect_to user_calendar_dashboard_url(current_user, @calendar, staff_id: @task.staff.id, task_id: @task.id)
  end

  def update_by_drop
    @task = Task.only_valid.find_by(id: params[:id])
    ActiveRecord::Base.transaction do
      @task.update!(start_time: params[:start_time], end_time: params[:end_time])
      sync_google_calendar_update(@task)
      LineBot.new.push_message_with_edit_task(@task, @task.store_member.line_user_id) if @task.store_member.line_user_id
      NotificationMailer.send_edit_task_to_user(@task, @calendar.user, @calendar).deliver if @task.store_member.email
    end
    render json: 'success'
  rescue StandardError
    sync_google_calendar_update(@task.reload)
    render json: @task.errors.full_messages
  end

  def destroy
    @task = Task.only_valid.find_by(id: params[:id])
    ActiveRecord::Base.transaction do
      @task.destroy!
      sync_google_calendar_delete(@task)
      LineBot.new.push_message_with_delete_task(@task, @task.store_member.line_user_id) if @task.store_member.line_user_id
      NotificationMailer.send_delete_task_to_user(@task, @calendar.user, @calendar).deliver if @task.store_member.email
    end
    respond_to do |format|
      format.html { redirect_to user_calendar_dashboard_url(current_user, @calendar, staff_id: @task.staff.id), notice: '予約をキャンセルしました。' }
      format.json { head :no_content }
      format.js { render :destroy }
    end
  rescue StandardError
    # sync_google_calendar_delete(@task)
    flash[:warnnig] = '予約をキャンセルできませんでした。'
    redirect_to user_calendar_user_tasks_url(params[:user_id])
  end

  private

  def store_member_params
    params.require(:store_member).permit(:name, :email, :phone, :gender, :age)
  end

  def task_params
    params.require(:task).permit(:start_time, :end_time, :staff_id, :task_course_id, :memo, :request)
  end

  def sync_google_calendar_create(task)
    SyncCalendarService.new(task, task.staff, task.calendar).create_event if task.staff.google_calendar_id
  end

  def sync_google_calendar_update(task)
    SyncCalendarService.new(task, task.staff, task.calendar).update_event if task.staff.google_calendar_id
  end

  def sync_google_calendar_delete(task)
    SyncCalendarService.new(task, task.staff, task.calendar).delete_event if task.staff.google_calendar_id
  end
end
