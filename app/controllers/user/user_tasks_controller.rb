class User::UserTasksController < User::Base
    before_action :calendar

    def index
        @calendar = Calendar.find_by(calendar_name: params[:calendar_calendar_name])
        @q = Task.with_store_member.ransack(params[:q])
        @tasks = @q.result(distinct: true).page(params[:page]).per(10)
    end

    def show
        @task = Task.find(params[:id])
    end

    def update
        @task = Task.find(params[:id])
        task_course = @task.task_course
        # start_time = @task.start_time.to_s
        if @task.update(task_params) && @task.update(end_time: end_time(@task.start_time.to_s, task_course))
            flash[:success] = "予約を更新しました"
            redirect_to user_calendar_dashboard_url(current_user, @calendar)
        else
            flash[:success] = "予約の更新ができませんでした。"
            redirect_to user_calendar_dashboard_url(current_user, @calendar)
        end
    end

    def destroy
        @task = Task.find(params[:id])
        if @task.destroy
            respond_to do |format|
            format.html { redirect_to user_calendar_dashboard_url(current_user, params[:calendar_calendar_name]), notice: '予約をキャンセルしました。' }
            format.json { head :no_content }
            format.js {render :destroy}
            end
        else
            flash[:warnnig] = "予約をキャンセルできませんでした。"
            redirect_to user_calendar_user_tasks_url(params[:user_id])
        end
    end

    private
    def store_member_params
        params.require(:store_member).permit(:name, :email, :phone, :gender, :age)
    end

    def task_params
        params.require(:task).permit(:start_time, :end_time)
    end

end