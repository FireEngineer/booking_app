class Public::TasksController < Public::Base
  before_action :set_task, only: %i[complete destroy cancel]
  before_action :calendar_is_released?, except:[:processing, :task_create]

  require 'base64'
  require 'json'
  require 'jwt'
  require 'line/bot'
  require 'net/http'
  require 'uri'

  CHANNEL_ID = ENV['LINE_LOGIN_CHANNEL_ID']
  CHANNEL_SECRET = ENV['LINE_LOGIN_CHANNEL_SECRET']

  def index
    task = Task.new
    @calendar = Calendar.find_by(public_uid: params[:calendar_id])
    @display_time = @calendar.display_time
    @calendar_config = @calendar.calendar_config
    @interval_time = @calendar_config.interval_time
    @task_course = if params[:course_id]
                     TaskCourse.find(params[:course_id])
                   else
                     @calendar.task_courses.first
                   end
    if params[:staff_id]
      @staffs = Staff.where(id: params[:staff_id])
    else
      @staffs = @calendar.staffs.order(:id)
    end

    @user = @calendar.user
    @times = time_interval(@calendar)
    @today = Time.current
    one_month = [*Date.current.days_since(@calendar.start_date)..Date.current.weeks_since(@calendar.display_week_term)]
    @month = Kaminari.paginate_array(one_month).page(params[:page]).per(@calendar.end_date)
    @staffs_google_tasks = StaffsScheduleOutputer.public_staff_private(@staffs, @month)
    @regular_holiday_days = @calendar.regular_holiday_days
    @dw = ["日", "月", "火", "水", "木", "金", "土"]
    @iregular_holydays = @calendar.iregular_holidays(@month)
  end

  def new
    @calendar = Calendar.find_by(public_uid: params[:calendar_id])
    @user = @calendar.user
    @staff = Staff.find_by(id: params[:staff_id])
    @task_course = TaskCourse.find(params[:course_id])
    @store_member = StoreMember.new
    @task = @store_member.tasks.build(start_time: params[:start_time],
                                      end_time: end_time(params[:start_time], @task_course),
                                      staff_id: @staff&.id,
                                      task_course_id: @task_course.id,
                                      calendar_id: @calendar.id)
    any_staff?(@task)
  # rescue RuntimeError => e
  #   if e.message == "shiftが存在しません。"
  #     flash[:danger] = "指定された日付の予約はできません。"
  #     redirect_to calendar_tasks_url(@calendar)
  #   end
  end

  # ラインログインボタンでこのアクションが呼ばれる
  def redirect_register_line
    @calendar = Calendar.find_by(public_uid: params[:calendar_id])
    @user = @calendar.user
    @task_course = TaskCourse.find(params[:task_course_id])
    # 電話番号で、既存の会員データがあれば、そのデータを使用する
    if @store_member = StoreMember.find_by(phone: store_member_params['phone'])
      @store_member.is_allow_notice = params[:store_member]['is_allow_notice']
    else
      @store_member = StoreMember.new(store_member_params.merge(calendar_id: @calendar.id))
    end
    @task = @store_member.tasks.build(task_params.merge(calendar_id: @calendar.id, task_course_id: @task_course.id, staff_id: params[:staff_id]))
    any_staff?(@task) #予約に対応できるスタッフの確認
    if @store_member.save
      if params[:commit] == '予約（通知をEメールで受け取る）'
        task_notification(@task)
        flash[:success] = '予約が完了しました。'
        redirect_to calendar_task_complete_url(@calendar, @task)
      else
        redirect_uri = URI.escape(processing_url)
        state = SecureRandom.urlsafe_base64
        # このURLがラインログインへのURL
        @task.update(state: state, is_valid_task: false)
        url = LineAccess.redirect_url(CHANNEL_ID, redirect_uri, state)
        redirect_to url
      end
    else
      flash[:success] = @store_member.errors.messages.values.first.first
      redirect_to calendar_tasks_url(@calendar)
    end
  end

  def processing
    render layout: 'plane'
  end

  def task_create
    if @task = Task.only_invalid.find_by!(state: params[:state])
      begin
        @task.update(is_valid_task: true)
        # アクセストークンを取得
        redirect_uri = URI.escape(processing_url)
        @calendar = @task.calendar
        @task_course = @task.task_course
        if params[:code]
          get_access_token = LineAccess.get_access_token(CHANNEL_ID, CHANNEL_SECRET, params[:code], redirect_uri)
          # アクセストークンを使用して、BOTとお客との友達関係を取得
          friend_response = LineAccess.get_friend_relation(get_access_token['access_token'])
          # アクセストークンのIDトークンを"gem jwt"を利用してデコード
          line_user_id = LineAccess.decode_response(get_access_token)
          if friend_response['friendFlag'] == true
            @task.store_member.update(line_user_id: line_user_id)
            flash[:success] = '予約が完了しました。'
          else # ラインログインでボットと友達にならなかった時の処理
            flash[:success] = '予約が完了しました。'
            flash[:danger] = 'LINE連携はできませんでした。メールで通知をしました。'
          end
          task_notification(@task)
          redirect_to calendar_task_complete_url(@calendar, @task)
          return
        else #LINE連携がうまくいかなかった時（キャンセルした時）
          flash[:success] = '予約が完了しました。'
          flash[:danger] = 'LINE連携はできませんでした。メールで通知をしました。'
          redirect_to calendar_task_complete_url(@calendar, @task)
          return
        end
      rescue JWT::DecodeError
        puts "JWT::DecodeError"
        flash[:success] = '予約が完了しました。'
        redirect_to calendar_task_complete_url(@calendar, @task)
      end
    else
      flash.now[:danger] = 'LINE連携が正常に完了しませんでした。予約を最初からやり直してください。'
      render :error_line, layout: 'plane'
      return
    end
  end

  def complete; end

  def cancel
    cancelable_time = @calendar.calendar_config.cancelable_time
    if @task.start_time <= Time.current
      flash[:danger] = '予定時間を過ぎているので、キャンセルできません。'
      redirect_to calendar_tasks_url(@calendar)
    elsif @task.start_time > Time.current && @task.start_time <= Time.current.since(cancelable_time.hours).to_time
      flash[:danger] = "予定時間まで#{cancelable_time}時間を過ぎているので、キャンセルできません。直接お店まで電話してください。"
      redirect_to calendar_tasks_url(@calendar)
    end
  rescue ActiveRecord::RecordNotFound
    flash[:danger] = 'この予約はキャンセル済みか、存在しません。'
    redirect_to calendar_tasks_url(@calendar)
  end

  def destroy
    @task.destroy
    # googleカレンダー連携
    if @task.staff.google_calendar_id
      SyncCalendarService.new(@task, @task.staff, @task.calendar).delete_event
    end
    # 通知許可
    if @task.store_member.is_allow_notice?
      LineBot.new.push_message_with_delete_task(@task, @task.store_member.line_user_id) if @task.store_member.line_user_id
      NotificationMailer.send_delete_task_to_user(@task, @calendar.user, @calendar).deliver if @task.store_member.email
    end
    # スタッフ通知
    LineBotByStaff.new.push_message_with_task_cancel(@task, @task.staff.line_user_id)
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
    @task = Task.only_valid.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      flash[:danger] = 'キャンセル済みか存在しない予約です。'
      redirect_to calendar_tasks_url(@calendar)
  end

  def store_member_params
    params.require(:store_member).permit(:name, :email, :phone, :gender, :age, :is_allow_notice, tasks_attributes: %i[start_time end_time request])
  end

  def task_params
    params.require(:task).permit(:start_time, :end_time, :request)
  end

  # タスクのバリデーションチェック
  def check_task_validation(task, calendar)
    if task.invalid?
      flash[:danger] = 'この時間はすでに予約が入っております。'
      redirect_to calendar_tasks_url(calendar)
    end
  end

  # 予約カレンダーの表示間隔
  def time_interval(calendar)
    start_time = calendar.start_time
    end_time = calendar.end_time
    interval_time = calendar.display_interval_time
    array = []
    1.step do |i|
      array.push(Time.parse("#{start_time}:00") + interval_time.minutes * (i - 1))
      break if Time.parse("#{start_time}:00") + interval_time.minutes * (i - 1) == Time.parse("#{end_time}:00")
    end
    array
  end

  def any_staff?(task)
    unless task.any_staff_available?
      flash[:danger] = 'この時間はすでに予約が入っております。'
      redirect_to calendar_tasks_url(task.calendar, staff_id: task.staff&.id, course_id: task.task_course&.id)
    end
  end

  def task_notification(task)
    puts "通知処理開始"
    if task.staff.google_calendar_id
      SyncCalendarService.new(@task, @task.staff, @task.calendar).create_event
    end
    # 通知許可
    if task.store_member.is_allow_notice?
      LineBot.new.push_message(task, task.store_member.line_user_id) if task.store_member.line_user_id
      NotificationMailer.send_confirm_to_user(task, task.calendar.user, task.calendar).deliver if task.store_member.email
    end
    # スタッフ通知
    LineBotByStaff.new.push_message_with_task_create(task, task.staff.line_user_id)
    puts "通知処理終了"
  end


end
