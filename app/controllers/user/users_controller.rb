class User::UsersController < User::Base
  before_action :check_has_calendar

  def show
    @user = current_user
    @order_plans = @user.order_plans
  end

  def update
    @user = current_user
    if params[:user][:password].blank?
      params[:user].delete('password')
      params[:user].delete('password_confirmation')
    end
    if @user.update(user_params)
      sign_in(@user, bypass: true)
      flash[:success] = 'ユーザーの更新に成功しました。'
      redirect_to user_path(@user)
    else
      render action: :show
    end
  end

  private

  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation)
  end

  def check_has_calendar
    redirect_to google_auth_ident_form_url if current_user.calendars.first.nil?
  end
end
