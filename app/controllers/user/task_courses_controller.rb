class User::TaskCoursesController < User::Base
    before_action :calendar

    def new
        @task_course = TaskCourse.new()
    end

    def create
        @task_course = @calendar.task_courses.build(task_course_params)

        respond_to do |format|
        if @task_course.save!
            format.html { redirect_to user_calendar_url(current_user, @calendar), notice: 'コースを作成しました。' }
            format.json { render :show, status: :created, location: @task_course }
            format.js { @status = "success"}
        else
            format.html { redirect_to user_calendar_url(current_user, @calendar), notice: 'コース作成に失敗しました。' }
            format.json { render json: @task_course.errors, status: :unprocessable_entity }
            format.js { @status = "fail" }
        end
        end
    end

    def edit
        @task_course = TaskCourse.find(params[:id])
    end

    def update
        @task_course = TaskCourse.find(params[:id])

        respond_to do |format|
        if @task_course.update(task_course_params)
            format.html { redirect_to user_calendar_url(current_user, @calendar), notice: 'コースを更新しました。' }
            format.json { render :show, status: :created, location: @task_course }
            format.js { @status = "success"}
        else
            format.html { redirect_to user_calendar_url(current_user, @calendar), notice: 'コース更新に失敗しました。' }
            format.json { render json: @task_course.errors, status: :unprocessable_entity }
            format.js { @status = "fail" }
        end
        end
    end

    def destroy
        @task_course = TaskCourse.find(params[:id])

        respond_to do |format|
        if @task_course.destroy
            format.html { redirect_to user_calendar_url(current_user, @calendar), notice: 'コースを削除しました。' }
            format.json { render :show, status: :created, location: @task_course }
            format.js { @status = "success"}
        else
            format.html { redirect_to user_calendar_url(current_user, @calendar), notice: 'コース削除に失敗しました。' }
            format.json { render json: @task_course.errors, status: :unprocessable_entity }
            format.js { @status = "fail" }
        end
        end
    end

    private

    def task_course_params
        params.require(:task_course).permit(:title, :description, :course_time, :calendar_id)
    end

end
