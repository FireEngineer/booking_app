class GoogleAuthController < ApplicationController
  include Encryptor
  def callback
    client = Signet::OAuth2::Client.new(SyncCalendarService.client_options(current_staff))
    client.code = params[:code]
    response = client.fetch_access_token!
    current_staff.google_api_token = response.to_json
    current_staff.refresh_token = response["refresh_token"]
    # calendar = Google::Apis::CalendarV3::Calendar.new(discription: '', summary: (current_staff.email.sub(/@.*/, '') + '-todo'))
    # service = Google::Apis::CalendarV3::CalendarService.new
    # service.authorization = client
    # _calendar = service.insert_calendar(calendar)
    # calendar = current_staff.calendars.build(calendar_id: _calendar.id)
    current_staff.save
    Task.register_unregistered_tasks_in_staff_google_calendar(current_staff)
    # calendar.save
    flash[:success] = "googleカレンダーと連携が完了しました。"
    redirect_to user_calendar_dashboard_url(current_user, current_user.calendars.first)
  rescue Signet::AuthorizationError
    update_unlink(current_staff) #googleカレンダーのカラムをリセット
    flash[:danger] = "googleカレンダーとの連携に失敗しました。入力した値をもう一度確認してください。"
    redirect_to user_calendar_dashboard_url(current_user, current_user.calendars.first)
  end

  def redirect
    client = Signet::OAuth2::Client.new(SyncCalendarService.client_options(current_staff))
    redirect_to client.authorization_uri.to_s
  rescue StandardError => e
    puts errors_log(e)
    redirect_to google_auth_ident_form_url
  end

  def ident_form; end

  def identifier
    staff = current_staff
    if staff.update(params_identifier)
      staff.client_id = encrypt(staff.client_id)
      staff.client_secret = encrypt(staff.client_secret)
      staff.save
      redirect_to google_auth_redirect_url
    end
  end

  def unlink
    if update_unlink(current_staff)
      flash[:notice] = "googleカレンダーと連携を解除しました。"
      redirect_to user_calendar_dashboard_url(current_user, current_user.calendars.first)
    end
  end

  private

  def update_unlink(staff)
    staff.update(client_id: nil, client_secret:nil, google_api_token: nil, google_calendar_id: nil)
  end

  def params_identifier
    params.permit(:client_id, :client_secret, :google_calendar_id)
  end
end
