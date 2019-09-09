
require 'net/http'
require 'uri'
require 'jwt'


module LineAccess


    def redirect_url(channel_id, redirect_uri, state)
        "https://access.line.me/oauth2/v2.1/authorize?response_type=code&client_id=#{channel_id}&redirect_uri=#{redirect_uri}&state=#{state}&scope=openid%20profile&bot_prompt=aggressive"
    end



    def get_access_token(channel_id, channel_secret, code)
        if Rails.env == "production"
            redirect_uri = "#{ENV['PRODUCTION_HOST_URL']}/task_create"
        else
            redirect_uri = "#{ENV['DEVELOPMENT_HOST_URL']}/task_create"
        end
        uri = URI.parse("https://api.line.me/oauth2/v2.1/token")
        request = Net::HTTP::Post.new(uri)
        request.content_type = "application/x-www-form-urlencoded"
        request.set_form_data(
        "client_id" => "#{channel_id}",
        "client_secret" => "#{channel_secret}",
        "code" => "#{code}",
        "grant_type" => "authorization_code",
        "redirect_uri" => "#{redirect_uri}",
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

    def get_friend_relation(access_token)
        uri = URI.parse("https://api.line.me/friendship/v1/status")
        request = Net::HTTP::Get.new(uri)
        request["Authorization"] = "Bearer #{access_token}"

        req_options = {
            use_ssl: uri.scheme == "https",
        }

        response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
            http.request(request)
        end

        puts response.code
        JSON.parse(response.body)
    end

    def decode_response(response)
        decoded_id_token = JWT.decode(response["id_token"], nil, false) #gem 'jwt'を利用して、デコードして、user_idを取得
        return user_id = decoded_id_token[0]["sub"]
    end

    module_function :get_access_token, :redirect_url, :get_friend_relation, :decode_response

end
