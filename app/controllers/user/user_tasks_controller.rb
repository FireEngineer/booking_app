class User::UserTasksController < User::Base
    def index
        @calender = Calendar.find_by(calendar_name: params[:calendar_calendar_name])
        @q = Task.with_store_member.ransack(params[:q])
        @tasks = @q.result(distinct: true)
    end

    def show
        @task = Task.find(params[:id])
    end

    def destroy
        @task = Task.find(params[:id])
        if @task.destroy
            respond_to do |format|
            format.html { redirect_to user_calendar_user_tasks_url(current_user, params[:calendar_calendar_name]), notice: '予約をキャンセルしました。' }
            format.json { head :no_content }
            format.js {render :destroy}
            end
        else
            flash[:warnnig] = "予約をキャンセルできませんでした。"
            redirect_to user_calendar_user_tasks_url(params[:user_id])
        end
    end

end