class LawsController < ApplicationController
  def law; end

  def form
    shop_id = 'tshop00041183'
    order_id = SecureRandom.alphanumeric(10)
    pay = 5000
    shop_pass = 'rzrqu2t7'
    date_time = l(DateTime.current, format: :to_gmo_pay_time)

    test = "#{shop_id}|#{order_id}|#{pay}||#{shop_pass}|#{date_time}"
    @shop_pass_str = Digest::MD5.hexdigest(test)
  end

  def paymemt_callback; end
end
