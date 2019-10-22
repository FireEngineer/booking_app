class User::PaymentsController < ApplicationController
  protect_from_forgery :except => [:payment_callback, :registration_callback]

  def form
    shop_id = "tshop00041183"
    @order_id = SecureRandom.alphanumeric(10)
    pay = 5000
    shop_pass = "rzrqu2t7"
    @date_time = l(DateTime.current, format: :to_gmo_pay_time)

    @site_id = "tsite00036337"
    site_pass = "scx2xg8c"
    @member_id = 555555
    member_pass_str = "#{@site_id}|#{@member_id}|#{site_pass}|#{@date_time}"
    @member_pass_str = Digest::MD5.hexdigest(member_pass_str)


    shop_pass_str = "#{shop_id}|#{@order_id}|#{pay}||#{shop_pass}|#{@date_time}"
    @shop_pass_str = Digest::MD5.hexdigest(shop_pass_str)
  end

  def payment_callback
    site_id = "tsite00036337"
    member_id = 555555
    site_pass = "scx2xg8c"
    shop_pass = "rzrqu2t7"
    date_time = l(DateTime.current, format: :to_gmo_pay_time)
    member_pass_str = Digest::MD5.hexdigest("#{site_id}|#{member_id}|#{params[:ShopID]}|#{params[:OrderID]}|#{site_pass}|#{shop_pass}|#{date_time}")
    url = "https://pt01.mul-pay.jp/link/tshop00041183/Member/Edit?SiteID=#{site_id}&MemberID=#{member_id}&ShopID=#{params[:ShopID]}&OrderID=#{params[:OrderID]}&MemberPassString=#{member_pass_str}&RetURL=#{registration_callback_url}&DateTime=#{date_time}"
    if params[:NewCardFlag] == "1"
      redirect_to url
    end
  end

  def edit_credit
    site_id = "tsite00036337"
    member_id = 666666
    site_pass = "scx2xg8c"
    shop_id = "tshop00041183"
    shop_pass = "rzrqu2t7"
    date_time = l(DateTime.current, format: :to_gmo_pay_time)
    member_pass_str = Digest::MD5.hexdigest("#{site_id}|#{member_id}|#{shop_id}|#{params[:OrderID]}|#{site_pass}|#{shop_pass}|#{date_time}")
    @test_url = "https://pt01.mul-pay.jp/link/tshop00041183/Member/Edit?SiteID=#{site_id}&MemberID=#{member_id}&ShopID=#{params[:ShopID]}&OrderID=#{params[:OrderID]}&MemberPassString=#{member_pass_str}&RetURL=#{registration_callback_url}&DateTime=#{date_time}"
  end

  def registration_callback
    
  end

end
