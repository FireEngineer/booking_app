include Encryptor
class SyncCalendarService
  attr_accessor :task, :staff, :calendar

  def self.client_options(staff)
    option = {
      client_id: decrypt(staff.client_id),
      client_secret: decrypt(staff.client_secret),
      authorization_uri: 'https://accounts.google.com/o/oauth2/auth',
      token_credential_uri: 'https://www.googleapis.com/oauth2/v4/token',
      scope: Google::Apis::CalendarV3::AUTH_CALENDAR,
      redirect_uri: Rails.application.routes.url_helpers.google_auth_callback_url,
      access_type: "offline",
      approval_prompt: "force",
      grant_type: 'authorization_code'
    }
    option
  end
  
  def initialize(task, staff, calendar)
    @task = task
    @staff = staff
    @calendar = calendar
  end

  def self.notify(calendar)
    client = Signet::OAuth2::Client.new(SyncCalendarService.client_options(staff))
    client.update!(staff.google_api_token)
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
    refresh_token
    client = Signet::OAuth2::Client.new(SyncCalendarService.client_options(staff))
    client.update!(JSON.parse(staff.google_api_token))
    service = Google::Apis::CalendarV3::CalendarService.new
    service.authorization = client

    response = service.list_events(calendar_id,
                                   single_events: true,
                                   order_by: 'startTime',
                                   time_max: Date.today.since(ENV['CALENDAR_DISPLAY_TERM'].to_i.month).rfc3339,
                                   time_min: Date.today.rfc3339)
    puts 'Upcoming events:'
    puts 'No upcoming events found' if response.items.empty?
    array = []
    response.items.each do |event|
      array.push(
        [event.start.date_time || event.start.date,
         event.end.date_time || event.end.date,
         event.id
        ]
      )
    end
    array
  rescue Google::Apis::AuthorizationError
    refresh_token
    retry
  end

  def public_read_event(term)
    refresh_token
    client = Signet::OAuth2::Client.new(SyncCalendarService.client_options(staff))
    client.update!(JSON.parse(staff.google_api_token))
    service = Google::Apis::CalendarV3::CalendarService.new
    service.authorization = client
    response = service.list_events(calendar_id,
                                   single_events: true,
                                   order_by: 'startTime',
                                   time_max: term.last.rfc3339,
                                   time_min: term.first.rfc3339)
    puts 'Upcoming events:'
    puts 'No upcoming events found' if response.items.empty?
    array = []
    response.items.each do |event|
      array.push(
        [event.start.date_time || event.start.date,
         event.end.date_time || event.end.date,
         event.id
        ]
      )
    end
    array
  rescue Google::Apis::AuthorizationError
    refresh_token
    retry
  end

  def create_event
    client = Signet::OAuth2::Client.new(SyncCalendarService.client_options(staff))
    client.update!(JSON.parse(staff.google_api_token))
    service = Google::Apis::CalendarV3::CalendarService.new
    service.authorization = client
    service.insert_event(calendar_id, calendar_event)
    task.update!(google_event_id: task.calendar_event_uid)
  rescue Google::Apis::AuthorizationError
    refresh_token
    retry
  end

  def update_event
    client = Signet::OAuth2::Client.new(SyncCalendarService.client_options(staff))
    client.update!(JSON.parse(staff.google_api_token))
    service = Google::Apis::CalendarV3::CalendarService.new
    service.authorization = client
    service.update_event(calendar_id, task.calendar_event_uid, calendar_event)
  rescue Google::Apis::AuthorizationError
    refresh_token
    retry
  end

  def delete_event
    client = Signet::OAuth2::Client.new(SyncCalendarService.client_options(staff))
    client.update!(JSON.parse(staff.google_api_token))
    service = Google::Apis::CalendarV3::CalendarService.new
    service.authorization = client
    service.delete_event(calendar_id, task.calendar_event_uid)
  rescue Google::Apis::AuthorizationError
    refresh_token
    retry
  rescue Google::Apis::ClientError
    'already cancel'
  end

  private

  def refresh_token
    response = get_access_token
    staff.google_api_token = response
    staff.save!
  end

  def get_access_token
    uri = URI.parse("https://www.googleapis.com/oauth2/v4/token?refresh_token=#{staff.refresh_token}&client_id=#{decrypt(staff.client_id)}&client_secret=#{decrypt(staff.client_secret)}&grant_type=refresh_token")
    request = Net::HTTP::Post.new(uri)
    req_options = {
      use_ssl: uri.scheme == "https",
    }

    response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
      http.request(request)
    end

    response.code
    response.body
  end

  def calendar_event
    event = Google::Apis::CalendarV3::Event.new(
      id: task.calendar_event_uid,
      summary: "【TEL】#{task.store_member.name}",
      # location: '800 Howard St., San Francisco, CA 94103',
      description: "【セレブエンジニア電話相談】名前：#{task.store_member.name}、TEL：#{task.store_member.phone}、
      予約詳細：#{Rails.application.routes.url_helpers.user_calendar_dashboard_url(task.calendar.user, task.calendar, staff_id: task.staff.id, task_id: task.id)},
      お客様情報：#{Rails.application.routes.url_helpers.calendar_store_member_url(task.calendar, task.store_member)}",
      start: {
        date_time: I18n.l(task.start_time, format: :to_work_json),
        time_zone: 'Asia/Tokyo'
      },
      end: {
        date_time: I18n.l(task.end_time, format: :to_work_json),
        time_zone: 'Asia/Tokyo'
      },
      # recurrence: [
      #   'RRULE:FREQ=DAILY;COUNT=2'
      # ],
      # attendees: [
      #   { email: task.store_member.email.to_s }
      # ]
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
    staff.google_calendar_id
  end

  private

  def time(date, time)
    date_time = date.since(time.hours)
    "#{date_time.year}-#{date_time.month}-#{date_time.day}T#{date_time.hour}:00:00+09:00"
  end
end
