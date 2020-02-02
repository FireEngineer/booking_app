class User::MemberLogsController < User::Base
  before_action :calendar
  skip_before_action :authenticate_current_user!

  def create
    @store_member = StoreMember.find(params[:store_member_id])
    @member_log = @store_member.member_logs.build(params_member_log)
    if @member_log.save
      @member_logs = @store_member.member_logs.order(id: "desc")
      @status = 200
    else
      @status = 400
    end
  end

  def create_picture
    @store_member = StoreMember.find(params[:store_member_id])
    @member_log = @store_member.member_logs.build
    @log_picture = @member_log.log_pictures.build(picture: params[:file])
    if @member_log.save
      @member_logs = @store_member.member_logs.order(id: "desc")
      @status = 200
    else
      @status = 400
    end
  end

  def update
    @member_log = MemberLog.find(params[:id])
    if @member_log.update(params_member_log)
      @store_member = StoreMember.find(params[:store_member_id])
      @member_logs = @store_member.member_logs.order(id: "desc")
      @status = 200
    else
      @status = 400
    end
  end

  def destroy
    @member_log = MemberLog.find(params[:id])
    if @member_log.destroy
      @status = 200
      @store_member = StoreMember.find(params[:store_member_id])
      @member_logs = @store_member.member_logs.order(id: "desc")
    else
      @status = 400
    end
  end

  private

    def params_member_log
      params.require(:member_log).permit(:log_text)
    end

    # def params_member_log_picture
    #   params.require(:member_log).permit(:log_text, log_pictures_attributes:[picture:[]])
    # end

end
