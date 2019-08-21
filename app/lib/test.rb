require 'line/bot'
require 'net/http'
require 'uri'
require 'base64'
class Test


  def self.push

    message = {
      type: 'text',
      text: 'hello'
    }
    client = Line::Bot::Client.new { |config|
        config.channel_secret = "2a3591a3789e3937403903e9dd87cabd"
        config.channel_token = "s61bzMv2/Ta8mhRMaI9kP08sjtdQ0Kfa99ofal8PyOCa0QaNAnAtfrAmNEGO3bnigM0L7tHsPiqRy548ps8r0SXUPZazJKYhxS5sjle/OQ+2opbgYGrdrDYHZl5oKJQJ4i7n3Hi8XB8L91B1SZU4+AdB04t89/1O/w1cDnyilFU="
    }
    response = client.push_message("Ufe072271906fe09327e21afb69e51cac", message)
    p response
  end

end

  # # Don't forget to return a successful response
  # "OK"