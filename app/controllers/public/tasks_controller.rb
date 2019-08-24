class Public::TasksController < Public::Base
  before_action :set_task, only: [:complete, :destroy]
  before_action :authenticate_user!
  # before_action :check_calendar_info, only: [:new, :create]

  require "base64"

  # CHANNEL_ID = Admin.first.line_bot.channel_id
  # CHANNEL_SECRET = Admin.first.line_bot.channel_secret

  CHANNEL_ID = "1603141730"
  CHANNEL_SECRET = "a59f370b529454e32f779071d9b50454"

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
    staff_id = params[:staff_id] || @calendar.staffs.first.id
    @staff = Staff.find(staff_id)

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
    @task_course = TaskCourse.find(params[:course_id])
    @store_member = StoreMember.new()
    @task = @store_member.tasks.build(start_time: params[:start_time],
                                      end_time: end_time(params[:start_time], @task_course))
  end

  def redirect_register_line
    @calendar = Calendar.find_by(calendar_name: params[:calendar_calendar_name])
    @user = @calendar.user

    session[:calendar] = @calendar.id
    session[:user] = @user.id
    session[:store_member] = store_member_params
    session[:task] = task_params
    session[:task_course_id] = params[:task_course_id]
    # url = "https://www.google.com"
    redirect_uri = task_create_url
    state = SecureRandom.base64(10)
    # url = "https://access.line.me/oauth2/v2.1/authorize?response_type=code&client_id=#{client_id}&redirect_uri=#{redirect_uri}&state=#{state}&bot_prompt=normal&scope=openid%20profile"
    url = "https://access.line.me/oauth2/v2.1/authorize?response_type=code&client_id=#{CHANNEL_ID}&redirect_uri=#{redirect_uri}&state=#{state}&scope=openid%20profile&prompt=consent&bot_prompt=normal"
    redirect_to url
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
    params = `curl -X GET \
            -H "Authorization: Bearer #{test["access_token"]}" \
            https://api.line.me/friendship/v1/status`

    params = JSON.parse(params)
    
    if params["friendFlag"] == true
      @user = @calendar.user
      @task_course = TaskCourse.find(session[:task_course_id])
      @store_member = StoreMember.new(session[:store_member])
      @store_member.calendar = @calendar
      @task = @store_member.tasks.build(session[:task])
      @task.calendar = @calendar
      @task.task_course = @task_course

      respond_to do |format|
        begin
          if @store_member.save
            flash[:success] = '予約が完了しました。'
            format.html { redirect_to calendar_task_complete_path(@calendar, @task) }
            format.json { render :show, status: :created, location: @task }
          else
            flash.now[:danger] = "予約ができませんでした。"

            format.html { render :new }
            format.json { render json: @store_member.errors, status: :unprocessable_entity }
          end
        rescue
          flash[:warnning] = "この時間はすでに予約が入っております。"
          redirect_to calendar_tasks_url(@calendar)
        end
      end
    end
  end


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
    def store_member_params
      params.require(:store_member).permit(:name, :email, :phone, :gender, :age, tasks_attributes: [:start_time, :end_time])
    end

    def task_params
      params.require(:task).permit(:start_time, :end_time)
    end

    # def check_calendar_info
    #   calendar = Calendar.find_by(calendar_name: params[:calendar_calendar_name])
    #   task = calendar.tasks.build(start_time: params[:start_time])
    #   if task.invalid?
    #     flash[:warnning] = "この時間はすでに予約が入っております。"
    #     redirect_to calendar_tasks_url(params[:calendar_calendar_name])
    #   end
    # end

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
        # JSON.parse(decode_res)
      end
    end

    def end_time(start_time, task_course)
      t = Time.parse(start_time)
      t.since(task_course.course_time.minutes)
    end

end
