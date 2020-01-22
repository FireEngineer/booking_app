class Staff::StaffBase < User::Base
  skip_before_action :authenticate_current_user!
  before_action :authenticate_current_staff!

  def authenticate_current_staff!
    unless current_staff
      flash[:danger] = '権限がありません'
      redirect_to new_staff_session_url
    end
  end
end
