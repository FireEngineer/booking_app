class User::UsersController < User::Base
  before_action :authenticate_user!
  before_action :check_has_calendar

  def dashboard
    @user = current_user
    @calendars = @user.calendars
    @staff_shifts = Staff.first.staff_shifts.map do |shift|
                      { start: l(shift.work_start_time, format: :to_work_json),
                        end: l(shift.work_end_time, format: :to_work_json),
                        rendering: 'background' }
                    end.to_json
  end

  def show
    @user = current_user
  end

  def update
    @user = current_user
    if @user.update(user_params)
      flash[:success] = "ユーザーの更新に成功しました。"
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
      if current_user.calendars.first == nil
        redirect_to google_auth_ident_form_url
      end
    end

end
