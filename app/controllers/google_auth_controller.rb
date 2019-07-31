class GoogleAuthController < ApplicationController
  def callback
    client = Signet::OAuth2::Client.new(SyncCalendarService.client_options(current_user))
    client.code = params[:code]
    response = client.fetch_access_token!
    current_user.google_api_token = response
    calendar = Google::Apis::CalendarV3::Calendar.new({ discription: 'yosida-todo', summary:(current_user.email.sub(/@.*/, "")+'-todo')})
    service = Google::Apis::CalendarV3::CalendarService.new
    service.authorization = client
    _calendar = service.insert_calendar(calendar)
    calendar = current_user.calendars.build(calendar_id: _calendar.id)
    current_user.save
    calendar.save
    redirect_to calendar_tasks_path(calendar)
  end

  def redirect
    client = Signet::OAuth2::Client.new(SyncCalendarService.client_options(current_user))
    redirect_to client.authorization_uri.to_s
  rescue => e
    puts errors_log(e)
    redirect_to google_auth_ident_form_url
  end

  def ident_form

  end

  def identifier
    user = current_user
    if user.update(params_identifier)
      redirect_to google_auth_redirect_url
    end

  end

  private

  def params_identifier
    params.permit(:client_id, :client_secret)
  end
end
