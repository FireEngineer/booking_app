class Public::TasksController < Public::Base
  before_action :set_task, only: %i[complete destroy cancel]
  before_action :calendar_is_released?

  require 'base64'
  require 'json'
  require 'jwt'
  require 'line/bot'
  require 'net/http'
  require 'uri'

  # CHANNEL_ID = Admin.first.line_bot.channel_id
  # CHANNEL_SECRET = Admin.first.line_bot.channel_secret

  CHANNEL_ID = ENV['LINE_LOGIN_CHANNEL_ID']
  CHANNEL_SECRET = ENV['LINE_LOGIN_CHANNEL_SECRET']

  def index
    task = Task.new
    @calendar = Calendar.find_by(public_uid: params[:calendar_id])
    @task_course = if params[:course_id]
                     TaskCourse.find(params[:course_id])
                   else
                     @calendar.task_courses.first
                   end
    staff_id = params[:staff_id] || @calendar.staffs.first.id
    @staff = Staff.find(staff_id)

    @user = @calendar.user
    @times = time_interval(@calendar.start_time, @calendar.end_time)

    @today = Time.current
    # DBタスクデータを引き出す
    @events = @staff.tasks.map { |task| [task.start_time, task.end_time] }
    # @events = SyncCalendarService.new(task,@user,@calendar).read_event
    one_month = [*Date.current.days_since(@calendar.start_date)..Date.current.months_since(@calendar.display_week_term)]
    @month = Kaminari.paginate_array(one_month).page(params[:page]).per(@calendar.end_date)
  end

  def new
    @calendar = Calendar.find_by(public_uid: params[:calendar_id])
    @user = @calendar.user
    @staff = Staff.find(params[:staff_id])
    @task_course = TaskCourse.find(params[:course_id])
    @store_member = StoreMember.new
    @task = @store_member.tasks.build(start_time: params[:start_time],
                                      end_time: end_time(params[:start_time], @task_course),
                                      staff_id: @staff.id,
                                      task_course_id: @task_course.id,
                                      calendar_id: @calendar.id)
    check_task_validation(@task)
  end

  # ラインログインボタンでこのアクションが呼ばれる
  def redirect_register_line
    @calendar = Calendar.find_by(public_uid: params[:calendar_id])
    @user = @calendar.user
    if params[:commit] == 'そのまま予約する'
      task_create_without_line(params, store_member_params, task_params)
    else
      # セッションにフォーム値を保持して、ラインログイン後レコード保存
      session_in(@calendar, @user, store_member_params, task_params, params)
      redirect_uri = URI.escape(task_create_url)
      state = SecureRandom.base64(10)
      # このURLがラインログインへのURL
      url = LineAccess.redirect_url(CHANNEL_ID, redirect_uri, state)
      redirect_to url
    end
  end

  def task_create
    # ラインログインをキャンセルした時
    if params[:error]
      @calendar = Calendar.find_by(id: session[:calendar])
      @user = @calendar.user
      @staff = Staff.find(session[:staff_id])
      @task_course = TaskCourse.find(session[:task_course_id])
      @store_member = StoreMember.new
      @task = @store_member.tasks.build(start_time: session[:task]['start_time'],
                                        end_time: end_time(session[:task]['start_time'], @task_course),
                                        staff_id: @staff.id,
                                        task_course_id: @task_course.id,
                                        calendar_id: @calendar.id)
      check_task_validation(@task)
      flash.now[:success] = 'キャンセルしました。'
      render :new
      return
    end

    # ここからが正常処理
    # アクセストークンを取得
    get_access_token = LineAccess.get_access_token(CHANNEL_ID, CHANNEL_SECRET, params[:code])
    # アクセストークンを使用して、BOTとお客との友達関係を取得
    friend_response = LineAccess.get_friend_relation(get_access_token['access_token'])
    # アクセストークンのIDトークンを"gem jwt"を利用してデコード
    line_user_id = LineAccess.decode_response(get_access_token)

    # BOTと友達かどうか確認する。
    if friend_response['friendFlag'] == true
      task_create_with_line(session, line_user_id)
    else # ラインログインでボットと友達にならなかった時の処理
      @calendar = Calendar.find_by(id: session[:calendar])
      @user = @calendar.user
      @staff = Staff.find(session[:staff_id])
      @task_course = TaskCourse.find(session[:task_course_id])
      @store_member = StoreMember.new
      @task = @store_member.tasks.build(start_time: session[:task]['start_time'],
                                        end_time: end_time(session[:task]['start_time'], @task_course),
                                        staff_id: @staff.id,
                                        task_course_id: @task_course.id,
                                        calendar_id: @calendar.id)
      check_task_validation(@task)
      flash.now[:danger] = 'ラインボットと友達になってください'
      render :new
      return
    end
  end

  def complete; end

  def cancel
    cancelable_time = @calendar.calendar_config.cancelable_time
    if @task.start_time <= Time.current
      flash[:danger] = '予定時間を過ぎているので、キャンセルできません。'
      redirect_to calendar_tasks_path(@calendar)
    elsif @task.start_time > Time.current && @task.start_time <= Time.current.since(cancelable_time.hours).to_time
      flash[:danger] = "予定時間まで#{cancelable_time}時間を過ぎているので、キャンセルできません。直接お店まで電話してください。"
      redirect_to calendar_tasks_path(@calendar)
    end
  rescue ActiveRecord::RecordNotFound
    flash[:danger] = 'この予約はキャンセル済みか、存在しません。'
    redirect_to calendar_tasks_path(@calendar)
  end

  def destroy
    @task.destroy
    respond_to do |format|
      format.html { redirect_to calendar_task_cancel_complete_url(params[:calendar_id], @task), success: '予約をキャンセルしました。' }
      format.json { head :no_content }
      format.js { render :destroy }
    end
  end

  def cancel_complete
    @task = Task.only_deleted.find(params[:id])
    @calendar = Calendar.find_by(public_uid: params[:calendar_id])
  end

  # ==============================================================================================

  private

  def set_task
    @calendar = Calendar.find_by(public_uid: params[:calendar_id])
    @user = @calendar.user
    @task = Task.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      flash[:danger] = 'キャンセル済みか存在しない予約です。'
      redirect_to calendar_tasks_path(@calendar)
  end

  def store_member_params
    params.require(:store_member).permit(:name, :email, :phone, :gender, :age, tasks_attributes: %i[start_time end_time request])
  end

  def task_params
    params.require(:task).permit(:start_time, :end_time, :request)
  end

  # タスクのバリデーションチェック
  def check_task_validation(task)
    if task.invalid?
      flash[:warnning] = 'この時間はすでに予約が入っております。'
      redirect_to calendar_tasks_url(params[:id])
    end
  end

  # 予約カレンダーの表示間隔
  def time_interval(start_time, end_time)
    array = []
    1.step do |i|
      array.push(Time.parse("#{start_time}:00") + 10.minutes * (i - 1))
      break if Time.parse("#{start_time}:00") + 10.minutes * (i - 1) == Time.parse("#{end_time}:00")
    end
    array
  end

  # そのまま登録ボタンで予約する時の処理
  def task_create_without_line(params, store_member_params, task_params)
    @task_course = TaskCourse.find(params[:task_course_id])
    # 電話番号で、既存の会員データがあれば、そのデータを使用する
    if StoreMember.find_by(phone: store_member_params['phone'])
      @store_member = StoreMember.find_by(phone: store_member_params['phone'])
    else
      @store_member = StoreMember.new(store_member_params)
      @store_member.calendar = @calendar
    end
    @task = @store_member.tasks.build(task_params)
    @task.calendar = @calendar
    @task.task_course = @task_course
    @task.staff = Staff.find(params[:staff_id])
    if @store_member.save
      LineBot.new.push_message(@task, @task.store_member.line_user_id) if @task.store_member.line_user_id
      flash[:success] = '予約が完了しました。'
      redirect_to calendar_task_complete_path(@calendar, @task)
      return
    else
      @staff = @task.staff
      flash.now[:danger] = '予約ができませんでした。'
      render :new
      return
    end
  end

  def session_in(calendar, user, store_member_params, task_params, params)
    session[:calendar] = calendar.id
    session[:user] = user.id
    session[:store_member] = store_member_params
    session[:task] = task_params
    session[:task_course_id] = params[:task_course_id]
    session[:staff_id] = params[:staff_id]
  end

  def task_create_with_line(session, line_user_id)
    @calendar = Calendar.find(session[:calendar])
    @user = @calendar.user
    @task_course = TaskCourse.find(session[:task_course_id])
    # 電話番号で、既存の会員データがあれば、そのデータを使用する
    if StoreMember.find_by(phone: session[:store_member]['phone'])
      @store_member = StoreMember.find_by(phone: session[:store_member]['phone'])
    else
      @store_member = StoreMember.new(session[:store_member])
      @store_member.calendar = @calendar
    end
    @task = @store_member.tasks.build(session[:task])
    @task.calendar = @calendar
    @task.task_course = @task_course
    @task.staff = Staff.find(session[:staff_id])
    @staff = @task.staff
    if @store_member.save
      @store_member.update(line_user_id: line_user_id)
      LineBot.new.push_message(@task, line_user_id)
      flash[:success] = '予約が完了しました。'
      redirect_to calendar_task_complete_path(@calendar, @task)
    else
      flash.now[:danger] = '予約ができませんでした。'
      render :new
    end
  end
end
