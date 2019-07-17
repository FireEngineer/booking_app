class ApplicationController < ActionController::Base

  def after_sign_in_path_for(resource)
    user_tasks_index_path(current_user) # ログイン後に遷移するpathを設定
  end

  # def after_sign_out_path_for(resource)
  #   new_user_session_path # ログアウト後に遷移するpathを設定
  # end


  private
  def check_calendar_info
    redirect_to google_auth_redirect_path if current_user.calendar_id.blank?
  end
end
