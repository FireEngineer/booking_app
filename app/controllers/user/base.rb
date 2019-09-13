class User::Base < ApplicationController
  before_action :authenticate_user!
    layout 'user'

    # def after_sign_in_path_for(resource)
    #     if current_admin
    #       dash_board_top_path(resource)
    #     elsif !current_user.client_id
    #       google_auth_ident_form_path
    #     else
    #       user_calendar_dashboard_path(current_user, current_user.calendars.first) # ログイン後に遷移するpathを設定
    #     end
    # end

    def calendar
        calendar_params = params[:calendar_id] || params[:id]
        @calendar = Calendar.find_by(public_uid: calendar_params)
        @q = Task.with_store_member.ransack(params[:q])
    end

end
