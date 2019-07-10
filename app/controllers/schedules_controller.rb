class SchedulesController < ApplicationController
  require "line_notify"
  require "google_api"
  
  before_action :schedule_valid?, only: [:form]
  
  def top
    unless Config.exists?
      initialize_config
    end
    config = Config.first
    @times = [*config.start_hour..config.end_hour]
    @today = Time.current
    @events = GoogleApi.api
    one_month = [*Date.current.days_since(config.start_day)..Date.current.weeks_since(config.end_day)]
    @month = Kaminari.paginate_array(one_month).page(params[:page])
    @wild_time = []
    @wild_day = []
  end
  
  def form
    @schedule = Schedule.new
  end
  
  def complete
    @schedule = Schedule.find(params[:schedule_id])
  end
  
  def fail_page
  end
  
  def create_event
    @schedule = Schedule.new(params_schedule)
    # ActiveRecord::Base.transaction do
      if @schedule.save # 保存に失敗した場合は強制的に例外処理へ
        event_create_result = GoogleApi.create_event(@schedule)
        @schedule.update(google_event_id: event_create_result.id)
        LineNotify.send(@schedule)
        ScheduleMailer.send_mail(@schedule).deliver_now
        flash[:succese] = "予約が完了しました！"
        redirect_to complete_url(schedule_id: @schedule.id)
      else
        flash[:danger] = "予約に失敗しました。<br>"
        @schedule.errors.full_messages.each { |msg| flash[:danger] += "&emsp;" + msg + "<br>" }
        redirect_to fail_page_url
      end
    # end
    # トランザクションのせいでバリデーションが聴いてないかも。
    # だけど普通に成功していても、予約が失敗しましたになる。
  end
  
  def cancel
    @schedule = Schedule.find_by(google_event_id: params[:id])
    if @schedule == nil
      flash[:notice] = "キャンセル済みの予定です。"
      redirect_to root_url
    end
  end
  
  def delete_event
    @schedule = Schedule.find_by(google_event_id: params[:id])
    if @schedule.destroy
      GoogleApi.delete_event(@schedule)
    end
    redirect_to root_url, notice: "予定をキャンセルしました。"
  end
  
  def googled5676385e1aedf67
  end
  
  private
  
    def params_schedule
      params.require(:schedule).permit(:name, :email, :date_time, :phone)
    end
    
    
    def schedule_valid?
      schedule = Schedule.new(date_time: params[:date_time], name: "テスト", email: "test@test.com", phone: "00000000000")
      if schedule.invalid?
        flash[:notice] = "この時間は既に予約が入っています。"
        redirect_to root_url
      end
    end
end
