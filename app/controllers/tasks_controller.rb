class TasksController < ApplicationController
  before_action :set_task, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!
  before_action :check_calendar_info

  # GET /tasks
  # GET /tasks.json
  def index
    task = Task.new
    # @tasks = SyncCalendarService.new(task,current_user).read_event
    # unless Config.exists?
    #   initialize_config
    # end
    # config = Config.first
    @times = [*10..22]
    @today = Time.current
    @events = SyncCalendarService.new(task,current_user).read_event
    one_month = [*Date.current.days_since(1)..Date.current.weeks_since(10)]
    @month = Kaminari.paginate_array(one_month).page(params[:page]).per(7)
    @wild_time = []
    @wild_day = []
  end

  def new
    @task = Task.new(date_time: params[:date_time])
  end

  # POST /tasks
  # POST /tasks.json
  def create
    user = User.find(params[:user_id])
    @task = user.tasks.build(task_params)

    respond_to do |format|
      if @task.save
        format.html { redirect_to user_task_complete_url(user, @task), notice: '予約が完了しました。' }
        format.json { render :show, status: :created, location: @task }
      else
        format.html { render :new }
        format.json { render json: @task.errors, status: :unprocessable_entity }
      end
    end
  end

  def complete
    @task = Task.find(params[:id])
  end

  def cancel
    @task = Task.find(params[:id])
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
      @task = current_user.tasks.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def task_params
      params.require(:task).permit(:title, :content, :due_at, :date_time, :email, :phone, :name)
    end
end
