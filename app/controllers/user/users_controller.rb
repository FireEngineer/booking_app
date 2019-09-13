class User::UsersController < User::Base
  before_action :check_has_calendar
  before_action :calendar

  def dashboard
    @staffs = @calendar.staffs
    @staff = Staff.find_by(id: params[:staff_id]) || @calendar.staffs.first
    staff_shifts = staff_shifts(@staff)
    staff_tasks = staff_tasks(@staff)
    @events = (staff_shifts + staff_tasks)&.to_json
  end

  def show
    @user = current_user
  end

  def update
    @user = current_user
    if @user.update(user_params)
      flash[:success] = 'ユーザーの更新に成功しました。'
      redirect_to user_path(@user)
    else
      render action: :show
    end
  end

  private

  def user_params
    params.require(:user).permit(:email, :line_token, :client_id, :client_secret)
  end

  def check_has_calendar
    redirect_to google_auth_ident_form_url if current_user.calendars.first.nil?
  end
end
