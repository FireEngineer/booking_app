class User::TaskCoursesController < User::Base
  before_action :calendar

  def index; end

  def new
    @task_course = TaskCourse.new
  end

  def create
    @task_course = @calendar.task_courses.build(task_course_params)
    if @task_course.save
      flash[:success] = 'コースを作成しました。'
      redirect_to user_calendar_task_courses_url(current_user, @calendar)
    end
  end

  def edit
    @task_course = TaskCourse.find(params[:id])
  end

  def update
    @task_course = TaskCourse.find(params[:id])
    if @task_course.update(task_course_params)
      flash[:success] = 'コースを更新しました。'
      redirect_to user_calendar_task_courses_url(current_user, @calendar)
    end
  end

  def destroy
    @task_course = TaskCourse.find(params[:id])

    respond_to do |format|
      if @task_course.destroy
        format.html { redirect_to user_calendar_task_courses_url(current_user, @calendar), notice: 'コースを削除しました。' }
        format.json { render :show, status: :created, location: @task_course }
        format.js { @status = 'success' }
      else
        format.html { redirect_to user_calendar_task_courses_url(current_user, @calendar), notice: 'コース削除に失敗しました。' }
        format.json { render json: @task_course.errors, status: :unprocessable_entity }
        format.js { @status = 'fail' }
      end
    end
  end

  private

  def task_course_params
    params.require(:task_course).permit(:title, :description, :course_time, :charge, :calendar_id, :is_tax_included, :is_more_than, :picture)
  end
end
