
require 'net/http'
require 'uri'

module LineAccess


    def get_access_token(channel_id, channel_secret, code)
        uri = URI.parse("https://api.line.me/oauth2/v2.1/token")
        request = Net::HTTP::Post.new(uri)
        request.content_type = "application/x-www-form-urlencoded"
        request.set_form_data(
        "client_id" => "#{channel_id}",
        "client_secret" => "#{channel_secret}",
        "code" => "#{code}",
        "grant_type" => "authorization_code",
        "redirect_uri" => "http://localhost:3000/task_create",
        )

        req_options = {
        use_ssl: uri.scheme == "https",
        }

        response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
            http.request(request)
        end
        puts response.code
        JSON.parse(response.body)
    end

    module_function :get_access_token

end