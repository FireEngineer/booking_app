class User::MemberPicturesController < User::Base
  def create
    calendar = Calendar.find_by(public_uid: params[:calendar_id])
    store_member = StoreMember.find(params[:store_member_id])
    member_picture = MemberPicture.new(params_member_picture)
    member_picture.store_member = store_member
    if member_picture.save
      flash[:success] = '画像をアップしました。'
      redirect_to calendar_store_member_url(calendar, store_member)
    end
  end

  def destroy; end

  private

  def params_member_picture
    params.require(:member_picture).permit(:picture)
  end
end
