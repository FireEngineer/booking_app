class TasksController < ApplicationController
  before_action :set_task, only: [:complete, :cancel, :destroy]
  before_action :authenticate_user!
  before_action :check_calendar_info

  # GET /tasks
  # GET /tasks.json
  def index
    task = Task.new
    @user = User.find(params[:user_id])
    @calendar = Calendar.find(params[:calendar_id])
    @times = [*@calendar.start_time..@calendar.end_time]
    @today = Time.current
    @events = SyncCalendarService.new(task,@user,@calendar).read_event
    one_month = [*Date.current.days_since(@calendar.start_date)..Date.current.weeks_since(@calendar.display_week_term)]
    @month = Kaminari.paginate_array(one_month).page(params[:page]).per(@calendar.end_date)
    @wild_time = []
    @wild_day = []
  end

  def new
    @user = User.find(params[:user_id])
    @calendar = Calendar.find(params[:calendar_id])
    @task = Task.new(date_time: params[:date_time])
  end

  # POST /tasks
  # POST /tasks.json
  def create
    @user = User.find(params[:user_id])
    @calendar = Calendar.find(params[:calendar_id])
    @task = Task.new(task_params)
    @task.calendar = @calendar

    respond_to do |format|
      if @task.save
        flash[:success] = '予約が完了しました。'
        format.html { redirect_to user_calendar_task_complete_path(@user, @calendar, @task) }
        format.json { render :show, status: :created, location: @task }
      else
        flash.now[:danger] = "予約ができませんでした。"
        format.html { render :new }
        format.json { render json: @task.errors, status: :unprocessable_entity }
      end
    end
  end

  def complete
    
  end

  def cancel
    
    rescue ActiveRecord::RecordNotFound
      flash[:notice] = "この予約はキャンセル済みか、存在しません。"
      redirect_to user_tasks_url(params[:user_id])
  end
  
  def destroy
    @task.destroy
    respond_to do |format|
      format.html { redirect_to user_tasks_url, notice: '予約をキャンセルしました。' }
      format.json { head :no_content }
      format.js {render :destroy}
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_task
      @user = User.find(params[:user_id])
      @calendar = Calendar.find(params[:calendar_id])
      @task = Task.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def task_params
      params.require(:task).permit(:title, :content, :due_at, :date_time, :email, :phone, :name)
    end
end
