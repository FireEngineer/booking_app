class User::LogPicturesController < User::Base
  skip_before_action :authenticate_current_user!

  def create
    if LogPicture.create(picture: params[:file], member_log_id: params[:member_log_id])
      @member_log = MemberLog.find(params[:member_log_id])
      @store_member = @member_log.store_member
      @calendar = @store_member.calendar
      @member_logs = @store_member.member_logs.order(id: "desc")
      @status = 200
    else
      @status = 400
    end
  end

end
