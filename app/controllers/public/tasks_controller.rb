class Public::TasksController < Public::Base
  before_action :set_task, only: [:complete, :destroy]
  before_action :authenticate_user!
  before_action :check_calendar_info, only: [:new, :create]

  require "base64"

  # CHANNEL_ID = Admin.first.line_bot.channel_id
  # CHANNEL_SECRET = Admin.first.line_bot.channel_secret

  CHANNEL_ID = "1610548594"
  CHANNEL_SECRET = "2a3591a3789e3937403903e9dd87cabd"

  # GET /tasks
  # GET /tasks.json
  def index
    task = Task.new
    @calendar = Calendar.find_by(calendar_name: params[:calendar_calendar_name])
    if params[:course_id]
      @task_course = TaskCourse.find(params[:course_id])
    else
      @task_course = @calendar.task_courses.first
    end
    @user = @calendar.user
    @times = time_interval(@calendar.start_time, @calendar.end_time)

    @today = Time.current
    @events = SyncCalendarService.new(task,@user,@calendar).read_event
    one_month = [*Date.current.days_since(@calendar.start_date)..Date.current.weeks_since(@calendar.display_week_term)]
    @month = Kaminari.paginate_array(one_month).page(params[:page]).per(@calendar.end_date)
    @wild_time = []
    @wild_day = []
  end

  def new
    @calendar = Calendar.find_by(calendar_name: params[:calendar_calendar_name])
    @user = @calendar.user
    task_course = TaskCourse.find(params[:course_id])
    @task = Task.new(start_time: params[:start_time])
  end

  def redirect_register_line
    @calendar = Calendar.find_by(calendar_name: params[:calendar_calendar_name])
    @user = @calendar.user

    session[:calendar] = @calendar.id
    session[:user] = @user.id
    session[:task] = task_params
    # url = "https://www.google.com"
    # 1603141730
    # redirect_uri = task_create_url
    # state = SecureRandom.base64(10)
    # # url = "https://access.line.me/oauth2/v2.1/authorize?response_type=code&client_id=#{client_id}&redirect_uri=#{redirect_uri}&state=#{state}&bot_prompt=normal&scope=openid%20profile"
    # url = "https://access.line.me/oauth2/v2.1/authorize?response_type=code&client_id=#{CHANNEL_ID}&redirect_uri=#{redirect_uri}&state=#{state}&scope=openid%20profile&prompt=consent&bot_prompt=normal"
    # redirect_to url
  end

  def task_create
    @calendar = Calendar.find(session[:calendar])
    test = `curl -X POST https://api.line.me/oauth2/v2.1/token \
      -H 'Content-Type: application/x-www-form-urlencoded' \
      -d 'grant_type=authorization_code' \
      -d "code=#{params[:code]}" \
      -d 'redirect_uri=http://localhost:3000/task_create' \
      -d "client_id=#{CHANNEL_ID}" \
      -d "client_secret=#{CHANNEL_SECRET}"`
    test = JSON.parse(test)
    decode_response(test["id_token"])
    debugger
    params = `curl -X GET \
            -H "Authorization: Bearer #{test["access_token"]}" \
            https://api.line.me/friendship/v1/status`

    params = JSON.parse(params)
    
    if params["friendFlag"] == true
      @user = @calendar.user
      @task = Task.new(session[:task])
      @task.calendar = @calendar

      respond_to do |format|
        if @task.save
          flash[:success] = '予約が完了しました。'
          format.html { redirect_to calendar_task_complete_path(@calendar, @task) }
          format.json { render :show, status: :created, location: @task }
        else
          flash.now[:danger] = "予約ができませんでした。"
          format.html { render :new }
          format.json { render json: @task.errors, status: :unprocessable_entity }
        end
      end
    end
  end

  # POST /tasks
  # POST /tasks.json
  # def create
  #   raise
  #   @calendar = Calendar.find_by(calendar_name: params[:calendar_calendar_name])
  #   @user = @calendar.user
  #   @task = Task.new(task_params)
  #   @task.calendar = @calendar

  #   respond_to do |format|
  #     if @task.save
  #       flash[:success] = '予約が完了しました。'
  #       format.html { redirect_to calendar_task_complete_path(@calendar, @task) }
  #       format.json { render :show, status: :created, location: @task }
  #     else
  #       flash.now[:danger] = "予約ができませんでした。"
  #       format.html { render :new }
  #       format.json { render json: @task.errors, status: :unprocessable_entity }
  #     end
  #   end
  # end

  def complete
  end

  def cancel
    set_task
    rescue ActiveRecord::RecordNotFound
      flash[:notice] = "この予約はキャンセル済みか、存在しません。"
      redirect_to calendar_tasks_path(@calendar)
  end
  
  def destroy
    @task.destroy
    respond_to do |format|
      format.html { redirect_to calendar_tasks_url(params[:calendar_calendar_name]), notice: '予約をキャンセルしました。' }
      format.json { head :no_content }
      format.js {render :destroy}
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_task
      @calendar = Calendar.find_by(calendar_name: params[:calendar_calendar_name])
      @user = @calendar.user
      @task = Task.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def task_params
      params.require(:task).permit(:title, :content, :due_at, :start_time, :email, :phone, :name)
    end

    def check_calendar_info
      calendar = Calendar.find_by(calendar_name: params[:calendar_calendar_name])
      task = calendar.tasks.build(start_time: params[:start_time])
      if task.invalid?
        flash[:warnning] = "この時間はすでに予約が入っております。"
        redirect_to calendar_tasks_url(params[:calendar_calendar_name])
      end
    end

    def time_interval(start_time, end_time)
      array = []
      1.step do |i|
          array.push(Time.parse("#{start_time}:00")+5.minutes*i)
          break if Time.parse("#{start_time}:00")+5.minutes*i == Time.parse("#{end_time}:00")
      end
      array
    end

    def decode_response(response)
      response.split(".").map do |res|
        decode_res = Base64.decode64(res)
        JSON.parse(decode_res)
      end
    end

end
