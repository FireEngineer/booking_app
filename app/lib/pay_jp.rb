class PayJp
  require 'payjp'
  API_KEY = 'sk_test_d2392c2fbb33eaae53381b10'.freeze

  # attr_reader :key

  def initialize
    Payjp.api_key = API_KEY
  end

  def create_prd(amount, display_name)
    response = `curl https://api.pay.jp/v1/products \
                -u #{API_KEY}: \
                -d amount=#{amount} \
                -d currency=jpy \
                -d "metadata[display_name]=#{display_name}"`
    JSON.parse(response)
  end

  def show_prd(prd_id)
    response = `curl https://api.pay.jp/v1/products/#{prd_id} \
    -u #{API_KEY}:`
    JSON.parse(response)
  end

  def index_prd(limit)
    response = `curl https://api.pay.jp/v1/products?limit=#{limit} \
    -u #{API_KEY}:`
    JSON.parse(response)
  end

  def update_prd(prd_id, time_stamp)
    response = `curl https://api.pay.jp/v1/products/#{prd_id} \
    -u #{API_KEY}: \
    -d invalid_after=#{time_stamp}`
    JSON.parse(response)
  end

  def delete_prd
    response = `curl https://api.pay.jp/v1/products/#{prd_id} \
    -u #{API_KEY}: \
    -XDELETE`
    JSON.parse(response)
  end
end
