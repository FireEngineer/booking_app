# require 'google/apis/calendar_v3'
require 'googleauth'
require 'googleauth/stores/file_token_store'
require 'date'
require 'active_support/time'
require 'fileutils'
# require 'google/apis/calendar_v3'
include ApplicationHelper

class GoogleApi
  CALENDAR_ID = 'changemymind6@gmail.com'.freeze

  OOB_URI = 'urn:ietf:wg:oauth:2.0:oob'.freeze
  APPLICATION_NAME = 'Google Calendar API Ruby Quickstart'.freeze
  CREDENTIALS_PATH = 'credentials.json'.freeze
  # The file token.yaml stores the user's access and refresh tokens, and is
  # created automatically when the authorization flow completes for the first
  # time.
  TOKEN_PATH = 'token.yaml'.freeze
  SCOPE = Google::Apis::CalendarV3::AUTH_CALENDAR

  ##
  # Ensure valid credentials, either by restoring from the saved credentials
  # files or intitiating an OAuth2 authorization. If authorization is required,
  # the user's default browser will be launched to approve the request.
  #
  # @return [Google::Auth::UserRefreshCredentials] OAuth2 credentials
  def self.authorize
    client_id = Google::Auth::ClientId.from_file(CREDENTIALS_PATH)
    token_store = Google::Auth::Stores::FileTokenStore.new(file: TOKEN_PATH)
    authorizer = Google::Auth::UserAuthorizer.new(client_id, SCOPE, token_store)
    user_id = 'default'
    credentials = authorizer.get_credentials(user_id)
    if credentials.nil?
      url = authorizer.get_authorization_url(base_url: OOB_URI)
      puts 'Open the following URL in the browser and enter the ' \
           "resulting code after authorization:\n" + url
      code = gets
      credentials = authorizer.get_and_store_credentials_from_code(
        user_id: user_id, code: code, base_url: OOB_URI
      )
    end
    credentials
  end

  def self.api
    # Initialize the API
    service = Google::Apis::CalendarV3::CalendarService.new
    service.client_options.application_name = APPLICATION_NAME
    service.authorization = authorize

    # Fetch the next 10 events for the user
    calendar_id = CALENDAR_ID

    response = service.list_events(calendar_id,
                                   single_events: true,
                                   order_by: 'startTime',
                                   time_max: Config.first.end_day.to_i.weeks.since.tomorrow.rfc3339,
                                   time_min: Date.today.rfc3339)
    puts 'Upcoming events:'
    puts 'No upcoming events found' if response.items.empty?
    array = []
    response.items.each do |event|
      # puts event.start.date_time || event.start.date
      array.push(
        [event.start.date_time || event.start.date,
         event.end.date_time || event.end.date]
      )
    end
    array
  end

  def self.create_event(schedule)
    service = Google::Apis::CalendarV3::CalendarService.new
    service.client_options.application_name = APPLICATION_NAME
    service.authorization = authorize
    event = Google::Apis::CalendarV3::Event.new(
      summary: "【TEL】#{schedule.name}",
      # location: '800 Howard St., San Francisco, CA 94103',
      description: "【セレブエンジニア電話相談】名前：#{schedule.name}、TEL：#{schedule.phone}",
      start: {
        date_time: time(schedule.date_time, 0).to_s,
        time_zone: 'Asia/Tokyo'
      },
      end: {
        date_time: time(schedule.date_time, 1).to_s,
        time_zone: 'Asia/Tokyo'
      },
      # recurrence: [
      #   'RRULE:FREQ=DAILY;COUNT=2'
      # ],
      attendees: [
        { email: schedule.email.to_s }
      ]
      # reminders: {
      #   use_default: false,
      #   overrides: [
      #     {method' => 'email', 'minutes: 24 * 60},
      #     {method' => 'popup', 'minutes: 10},
      #   ],
      # },
    )

    result = service.insert_event(CALENDAR_ID, event)
  end

  def self.delete_event(schedule)
    service = Google::Apis::CalendarV3::CalendarService.new
    service.client_options.application_name = APPLICATION_NAME
    service.authorization = authorize
    service.delete_event(CALENDAR_ID, schedule.google_event_id.to_s)
  end

  def self.destroy
    client_id = Google::Auth::ClientId.from_file(CREDENTIALS_PATH)
    token_store = Google::Auth::Stores::FileTokenStore.new(file: TOKEN_PATH)
    authorizer = Google::Auth::UserAuthorizer.new(client_id, SCOPE, token_store)
    user_id = 'default'
    authorizer.revoke_authorization(user_id)
  end
end
