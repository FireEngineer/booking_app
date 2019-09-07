class Public::TasksController < Public::Base
  before_action :set_task, only: [:complete, :destroy]
  before_action :calendar_is_released?

  require "base64"
  require 'json'
  require 'jwt'
  require 'line/bot'
  require 'net/http'
  require 'uri'

  # CHANNEL_ID = Admin.first.line_bot.channel_id
  # CHANNEL_SECRET = Admin.first.line_bot.channel_secret

  CHANNEL_ID = ENV['LINE_LOGIN_CHANNEL_ID']
  CHANNEL_SECRET = ENV['LINE_LOGIN_CHANNEL_SECRET']

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
    # DBタスクデータを引き出す
    @events = @staff.tasks.map {|task| [task.start_time, task.end_time]}
    # @events = SyncCalendarService.new(task,@user,@calendar).read_event
    one_month = [*Date.current.days_since(@calendar.start_date)..Date.current.months_since(@calendar.display_week_term)]
    @month = Kaminari.paginate_array(one_month).page(params[:page]).per(@calendar.end_date)
  end

  def new
    @calendar = Calendar.find_by(calendar_name: params[:calendar_calendar_name])
    @user = @calendar.user
    @staff = Staff.find(params[:staff_id])
    @task_course = TaskCourse.find(params[:course_id])
    @store_member = StoreMember.new()
    @task = @store_member.tasks.build(start_time: params[:start_time],
                                      end_time: end_time(params[:start_time], @task_course),
                                      staff_id: @staff.id,
                                      task_course_id: @task_course.id,
                                      calendar_id: @calendar.id)
    check_task_validation(@task)
  end

  # ラインログインボタンでこのアクションが呼ばれる
  def redirect_register_line
    @calendar = Calendar.find_by(calendar_name: params[:calendar_calendar_name])
    @user = @calendar.user
    
    if params[:commit] == "そのまま予約する"
      @task_course = TaskCourse.find(params[:task_course_id])
      # 電話番号で、既存の会員データがあれば、そのデータを使用する
      if StoreMember.find_by(phone: store_member_params["phone"])
        @store_member = StoreMember.find_by(phone: store_member_params["phone"])
      else
        @store_member = StoreMember.new(store_member_params)
        @store_member.calendar = @calendar
      end
      @task = @store_member.tasks.build(task_params)
      @task.calendar = @calendar
      @task.task_course = @task_course
      @task.staff = Staff.find(params[:staff_id])
      begin
        if @store_member.save
          if @task.store_member.line_user_id
            LineBot.new().push_message(@task, @task.store_member.line_user_id)
          end
          flash[:success] = '予約が完了しました。'
          redirect_to calendar_task_complete_path(@calendar, @task)
          return
        else
          flash.now[:danger] = "予約ができませんでした。"
          render :new
          return
        end
      rescue e
        puts errors_log(e)
        flash[:warnning] = "この時間はすでに予約が入っております。"
        redirect_to calendar_tasks_url(@calendar)
        return
      end
    end
    # セッションにフォーム値を保持して、ラインログイン後レコード保存
    session[:calendar] = @calendar.id
    session[:user] = @user.id
    session[:store_member] = store_member_params
    session[:task] = task_params
    session[:task_course_id] = params[:task_course_id]
    session[:staff_id] = params[:staff_id]
    redirect_uri = task_create_url
    state = SecureRandom.base64(10)
    # このURLがラインログインへのURL
    url = LineAccess.redirect_url(CHANNEL_ID, redirect_uri, state)
    redirect_to url
  end

  def task_create
    # ラインログインをキャンセルした時
    if params[:error]
      @calendar = Calendar.find_by(id: session[:calendar])
      @user = @calendar.user
      @staff = Staff.find(session[:staff_id])
      @task_course = TaskCourse.find(session[:task_course_id])
      @store_member = StoreMember.new()
      @task = @store_member.tasks.build(start_time: session[:task]["start_time"],
                                        end_time: end_time(session[:task]["start_time"], @task_course),
                                        staff_id: @staff.id,
                                        task_course_id: @task_course.id,
                                        calendar_id: @calendar.id)
    check_task_validation(@task)
      flash.now[:notice] = "キャンセルしました。"
      render :new
      return
    end

  # ここからが正常処理
    # アクセストークンを取得
    get_access_token = LineAccess.get_access_token(CHANNEL_ID, CHANNEL_SECRET, params[:code])
    # アクセストークンを使用して、BOTとお客との友達関係を取得
    friend_response = LineAccess.get_friend_relation(get_access_token["access_token"])
    # アクセストークンのIDトークンを"gem jwt"を利用してデコード
    line_user_id = LineAccess.decode_response(get_access_token)

    # BOTと友達かどうか確認する。
    if friend_response["friendFlag"] == true
      @calendar = Calendar.find(session[:calendar])
      @user = @calendar.user
      @task_course = TaskCourse.find(session[:task_course_id])
      # 電話番号で、既存の会員データがあれば、そのデータを使用する
      if StoreMember.find_by(phone: session[:store_member]["phone"])
        @store_member = StoreMember.find_by(phone: session[:store_member]["phone"])
      else
        @store_member = StoreMember.new(session[:store_member])
        @store_member.calendar = @calendar
      end
      @task = @store_member.tasks.build(session[:task])
      @task.calendar = @calendar
      @task.task_course = @task_course
      @task.staff = Staff.find(session[:staff_id])

      begin
        if @store_member.save
          @store_member.update(line_user_id: line_user_id)
          LineBot.new().push_message(@task, line_user_id)
          flash[:success] = '予約が完了しました。'
          redirect_to calendar_task_complete_path(@calendar, @task)
        else
          flash.now[:danger] = "予約ができませんでした。"
          render :new
        end
      rescue
        flash[:warnning] = "この時間はすでに予約が入っております。"
        redirect_to calendar_tasks_url(@calendar)
      end
    else #ラインログインでボットと友達にならなかった時の処理
      @calendar = Calendar.find_by(id: session[:calendar])
      @user = @calendar.user
      @staff = Staff.find(session[:staff_id])
      @task_course = TaskCourse.find(session[:task_course_id])
      @store_member = StoreMember.new()
      @task = @store_member.tasks.build(start_time: session[:task]["start_time"],
                                        end_time: end_time(session[:task]["start_time"], @task_course),
                                        staff_id: @staff.id,
                                        task_course_id: @task_course.id,
                                        calendar_id: @calendar.id)
      check_task_validation(@task)
        flash.now[:notice] = "ラインボットと友達になってください"
        render :new
        return
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
    def set_task
      @calendar = Calendar.find_by(calendar_name: params[:calendar_calendar_name])
      @user = @calendar.user
      @task = Task.find(params[:id])
    end

    def store_member_params
      params.require(:store_member).permit(:name, :email, :phone, :gender, :age, tasks_attributes: [:start_time, :end_time, :request])
    end

    def task_params
      params.require(:task).permit(:start_time, :end_time, :request)
    end
    
    def check_task_validation(task)
      if task.invalid?
        flash[:warnning] = "この時間はすでに予約が入っております。"
        redirect_to calendar_tasks_url(params[:calendar_calendar_name])
      end
    end

    # 予約カレンダーの表示間隔
    def time_interval(start_time, end_time)
      array = []
      1.step do |i|
          array.push(Time.parse("#{start_time}:00")+15.minutes*(i-1))
          break if Time.parse("#{start_time}:00")+15.minutes*(i-1) == Time.parse("#{end_time}:00")
      end
      array
    end

    

    

end
