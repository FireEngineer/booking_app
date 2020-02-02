class User::StoreMembersController < User::Base
  before_action :calendar
  skip_before_action :authenticate_current_user!

  def index
    @member_q = @calendar.store_members.ransack(params[:q])
    @store_members = @member_q.result(distinct: true).page(params[:page]).per(10)
  end

  def show
    @store_member = StoreMember.find(params[:id])
    @tasks = @store_member.tasks.order(start_time: 'desc')
    @member_log = MemberLog.new()
    @member_logs = @store_member.member_logs.order(id: "desc")
    @log_picture = @member_log.log_pictures.build
  end

  def store_member_task_show
    @task = Task.only_valid.find(params[:id])
  end

  def update
    @store_member = StoreMember.find(params[:id])
    if @store_member.update(params_store_member)
      @status = 200
    else
      @status = 400
    end
  end

  def update_task
    @task = Task.only_valid.find(params[:id])
    if @task.update(params_member_task)
      flash[:success] = '会員の予定を更新しました。'
      redirect_to calendar_store_member_url(@calendar, @task.store_member)
    else
      flash[:danger] = '会員の予定を更新できませんでした。'
      redirect_to calendar_store_member_url(@calendar, @task.store_member)
    end
  end

  private

  def params_store_member
    params.require(:store_member).permit(:memo, :name, :email, :phone)
  end

  def params_member_task
    params.require(:task).permit(:memo)
  end
end
