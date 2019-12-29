require 'net/http'
require 'uri'
require 'jwt'

module LineAccess
  def redirect_url(channel_id, redirect_uri, state)
    "https://access.line.me/oauth2/v2.1/authorize?response_type=code&client_id=#{channel_id}&redirect_uri=#{redirect_uri}&state=#{state}&bot_prompt=aggressive&scope=openid%20profile"
  end

  def get_access_token(channel_id, channel_secret, code, redirect_uri)
    redirect_uri = redirect_uri
    uri = URI.parse('https://api.line.me/oauth2/v2.1/token')
    request = Net::HTTP::Post.new(uri)
    request.content_type = 'application/x-www-form-urlencoded'
    request.set_form_data(
      'client_id' => channel_id.to_s,
      'client_secret' => channel_secret.to_s,
      'code' => code.to_s,
      'grant_type' => 'authorization_code',
      'redirect_uri' => redirect_uri.to_s
    )

    req_options = {
      use_ssl: uri.scheme == 'https'
    }

    response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
      http.request(request)
    end
    puts response.code
    JSON.parse(response.body)
  end

  def get_friend_relation(access_token)
    uri = URI.parse('https://api.line.me/friendship/v1/status')
    request = Net::HTTP::Get.new(uri)
    request['Authorization'] = "Bearer #{access_token}"

    req_options = {
      use_ssl: uri.scheme == 'https'
    }

    response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
      http.request(request)
    end

    puts response.code
    JSON.parse(response.body)
  end

  def decode_response(response)
    decoded_id_token = JWT.decode(response['id_token'], nil, false) # gem 'jwt'を利用して、デコードして、user_idを取得
    user_id = decoded_id_token[0]['sub']
  end

  module_function :get_access_token, :redirect_url, :get_friend_relation, :decode_response
end
