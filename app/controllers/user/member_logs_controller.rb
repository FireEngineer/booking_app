class User::MemberLogsController < User::Base
  before_action :calendar
  skip_before_action :authenticate_current_user!

  def create
    @store_member = StoreMember.find(params[:store_member_id])
    @member_log = @store_member.member_logs.build(params_member_log)

    if @member_log.save
      @member_logs = @store_member.member_logs.order(id: "desc")
    else
    end
  end

  private

    def params_member_log
      params.require(:member_log).permit(:log_text)
    end

end
