class User::UserTasksController < User::Base
    def index
        @calendars = current_user.calendars
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