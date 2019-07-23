require 'net/http'
require 'uri'

class LineNotifyService

  attr_accessor :task, :user, :calendar
  TOKEN = "0Ga2CHkIUOrzbppA7AV1CokKSVq6nmeywFSeDxVvzgI"
  URI = URI.parse("https://notify-api.line.me/api/notify")

  def initialize(task, user, calendar)
    @task = task
    @user = user
    @calendar = calendar
  end

  def make_request
    request = Net::HTTP::Post.new(URI)
    request["Authorization"] = "Bearer #{user.line_token}"
    request.set_form_data(message: msg(task))
    request
  end

  def send
    request = make_request
    response = Net::HTTP.start(URI.hostname, URI.port, use_ssl: URI.scheme == "https") do |https|
      https.request(request)
    end
  end

  private
    def msg(task)
        message = <<-TEXT
        予定が登録されました!
        ===================
        ・名前
          #{task.name}
        ・email
          #{task.email}
        ・TEL
          #{task.phone}
        ・開始時間
          #{task.date_time.strftime("%Y年%-m月%-d日 %-H時")}~
          #{task.date_time.since(1.hours).hour}時
        ・キャンセルURL
          #{ if Rails.env == "development" then "http://localhost:3000/users/#{user.id}/calendars/#{calendar.id}/tasks/#{task.id}/cancel" end }
        ===================
      TEXT
    end
end
