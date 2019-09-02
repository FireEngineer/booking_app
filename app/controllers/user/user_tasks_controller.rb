class User::UserTasksController < User::Base
    before_action :calendar

    def index
        @calendar = Calendar.find_by(calendar_name: params[:calendar_calendar_name])
        @q = Task.with_store_member.ransack(params[:q])
        @tasks = @q.result(distinct: true).page(params[:page]).per(10)
    end

    def new
        @calendar = Calendar.find_by(calendar_name: params[:calendar_calendar_name])
        @store_member = StoreMember.new()
        @task = Task.new(start_time: params[:start_time])
    end

    def create
        @calendar = Calendar.find_by(calendar_name: params[:calendar_calendar_name])
        if StoreMember.find_by(phone: params[:store_member]["phone"])
            @store_member = StoreMember.find_by(phone: params[:store_member]["phone"])
        else
            @store_member = StoreMember.new(store_member_params)
        end
        @store_member.calendar = @calendar
        task = @store_member.tasks.build(task_params)
        task_course = TaskCourse.find_by(id: task_params["task_course_id"])
        task.end_time = end_time(task.start_time.to_s, task_course)
        task.calendar = @calendar
        if @store_member.save
            flash[:success] = "予約を作成しました"
            redirect_to user_calendar_dashboard_url(current_user, @calendar)
        else
            flash[:error] = @store_member.errors.full_messages[0]
            redirect_to user_calendar_dashboard_url(current_user, @calendar)
        end
    end

    def show
        @task = Task.find(params[:id])
    end

    def update
        @task = Task.find(params[:id])
        @task.attributes = task_params
        task_course = @task.task_course
        @task.end_time = end_time(@task.start_time.to_s, task_course)
        if @task.save
            flash[:success] = "予約を更新しました"
            redirect_to user_calendar_dashboard_url(current_user, @calendar)
        else
            flash[:success] = "予約の更新ができませんでした。"
            redirect_to user_calendar_dashboard_url(current_user, @calendar)
        end
    end

    def update_by_drop
        @task = Task.find_by(id: params[:id])
        if @task.update(start_time: params[:start_time], end_time: params[:end_time])
            render json: "success"
        else
            render json: @task.errors.full_messages
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
        params.require(:task).permit(:start_time, :end_time, :staff_id, :task_course_id)
    end



end