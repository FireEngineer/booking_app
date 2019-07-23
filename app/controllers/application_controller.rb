class ApplicationController < ActionController::Base

  def after_sign_in_path_for(resource)
    unless current_user.client_id
      google_auth_ident_form_path
    else
      user_dashboard_path(current_user) # ログイン後に遷移するpathを設定
    end
  end

  def after_sign_out_path_for(resource)
    new_user_session_path # ログアウト後に遷移するpathを設定
  end


  private
  def check_calendar_info
    calendar = Calendar.find(params[:calendar_id])
    redirect_to google_auth_redirect_path if calendar.calendar_id.blank?
  end
end
