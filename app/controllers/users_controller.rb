class UsersController < ApplicationController

  def setting
    @user = current_user
    @calendars = @user.calendars
  end

end
