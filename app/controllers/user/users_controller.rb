class User::UsersController < User::Base

  def dashboard
    @user = current_user
    @calendars = @user.calendars
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

end
