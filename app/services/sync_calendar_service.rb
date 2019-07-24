class SyncCalendarService

  attr_accessor :task, :user, :calendar

  def self.client_options(user)
    option = {
      client_id: user.client_id,
      client_secret: user.client_secret,
      authorization_uri: 'https://accounts.google.com/o/oauth2/auth',
      token_credential_uri: 'https://www.googleapis.com/oauth2/v4/token',
      scope: Google::Apis::CalendarV3::AUTH_CALENDAR,
      redirect_uri: Rails.application.routes.url_helpers.google_auth_callback_url,
      additional_parameters: {prompt:'consent'},
    }
    option
  end

  def initialize(task,user,calendar)
    @task = task
    @user = user
    @calendar = calendar
  end

  def self.notify(calendar)
    client = Signet::OAuth2::Client.new(SyncCalendarService.client_options(user))
    client.update!(user.google_api_token)
    service = Google::Apis::CalendarV3::CalendarService.new
    service.authorization = client
    client.execute!(
      api_method: service.events.watch,
      parameters: { calendarId: calendar.calendar_id },
      body_object: {
        id: '<CHANNEL_ID>',
        type: 'web_hook',
        address: '<YOUR_RECEIVING_URL>'
      }
    )
  end

  def read_event
    client = Signet::OAuth2::Client.new(SyncCalendarService.client_options(user))
    client.update!(user.google_api_token)
    service = Google::Apis::CalendarV3::CalendarService.new
    service.authorization = client
    
    response = service.list_events(calendar_id,
                                   single_events: true,
                                   order_by: 'startTime',
                                   time_max: Date.today.since(calendar.display_week_term.week).rfc3339,
                                   time_min: Date.today.since(calendar.start_date.day).rfc3339)
                                  #  Config.first.end_day.to_i
    puts 'Upcoming events:'
    puts 'No upcoming events found' if response.items.empty?
    array = []
    response.items.each do |event|
      # puts event.start.date_time || event.start.date
      array.push( 
                  [ event.start.date_time || event.start.date, 
                  event.end.date_time || event.end.date ] 
                )
    end
    array
  rescue Google::Apis::AuthorizationError
    refresh_token
    retry
  end

  def create_event
    client = Signet::OAuth2::Client.new(SyncCalendarService.client_options(user))
    client.update!(user.google_api_token)
    service = Google::Apis::CalendarV3::CalendarService.new
    service.authorization = client
    service.insert_event(calendar_id, calendar_event)
    rescue Google::Apis::AuthorizationError
      refresh_token
      retry
  end

  def update_event
    client = Signet::OAuth2::Client.new(SyncCalendarService.client_options(user))
    client.update!(user.google_api_token)
    service = Google::Apis::CalendarV3::CalendarService.new
    service.authorization = client
    service.update_event(calendar_id, task.calendar_event_uid, calendar_event)
    rescue Google::Apis::AuthorizationError
      refresh_token
      retry
  end

  def delete_event
    client = Signet::OAuth2::Client.new(SyncCalendarService.client_options(user))
    client.update!(user.google_api_token)
    service = Google::Apis::CalendarV3::CalendarService.new
    service.authorization = client
    service.delete_event(calendar_id, task.calendar_event_uid)
    rescue Google::Apis::AuthorizationError
      refresh_token
      retry
    rescue Google::Apis::ClientError
      "already cancel"
  end

  private

  def refresh_token
    client = Signet::OAuth2::Client.new(SyncCalendarService.client_options(user))
    client.update!(user.google_api_token)
    response = client.refresh!
    user.google_api_token = user.google_api_token.merge(response)
  end

  def calendar_event
    event = Google::Apis::CalendarV3::Event.new(
                          id: task.calendar_event_uid,
                          summary: "【TEL】#{task.name}",
                          # location: '800 Howard St., San Francisco, CA 94103',
                          description: "【セレブエンジニア電話相談】名前：#{task.name}、TEL：#{task.phone}、
                          キャンセルURL：#{ if Rails.env == "development" then "http://localhost:3000/calendars/#{calendar.calendar_name}/tasks/#{task.id}/cancel" end }",
                          start: {
                            date_time: "#{time(task.date_time, 0)}",
                            time_zone: 'Asia/Tokyo',
                          },
                          end: {
                            date_time: "#{time(task.date_time, 1)}",
                            time_zone: 'Asia/Tokyo',
                          },
                          # recurrence: [
                          #   'RRULE:FREQ=DAILY;COUNT=2'
                          # ],
                          attendees: [
                            {email: "#{task.email}"},
                          ],
                          # reminders: {
                          #   use_default: false,
                          #   overrides: [
                          #     {method' => 'email', 'minutes: 24 * 60},
                          #     {method' => 'popup', 'minutes: 10},
                          #   ],
                          # },
                        )
  end

  def calendar_id
    calendar.calendar_id
  end

  private
    def time(date, time)
      date_time = date.since(time.hours)
      "#{date_time.year}-#{date_time.month}-#{date_time.day}T#{date_time.hour}:00:00+09:00"
    end
end
