class User::PaymentsController < ApplicationController
  before_action :authenticate_user!
  protect_from_forgery :except => [:payment_callback, :registration_callback]

  def form
    shop_id = ENV['SHOP_ID']
    order_id = SecureRandom.alphanumeric(10)
    pay = SystemPlan.first.charge
    shop_pass = ENV["SHOP_PASS"]
    date_time = l(DateTime.current, format: :to_gmo_pay_time)

    site_id = ENV["SITE_ID"]
    site_pass = ENV["SITE_PASS"]
    member_id = current_user.member_id
    member_pass_str = "#{site_id}|#{member_id}|#{site_pass}|#{date_time}"
    member_pass_str = Digest::MD5.hexdigest(member_pass_str)


    shop_pass_str = "#{shop_id}|#{order_id}|#{pay}||#{shop_pass}|#{date_time}"
    shop_pass_str = Digest::MD5.hexdigest(shop_pass_str)
    if browser.device.mobile?
      @test_url = "https://pt01.mul-pay.jp/link/tshop00041183/Multi/Entry?ShopID=tshop00041183&OrderID=#{order_id}&Amount=5000&DateTime=#{date_time}&ShopPassString=#{shop_pass_str}&RetURL=http://localhost:3000/payments/payment_callback&UseCredit=1&JobCd=CHECK&SiteID=#{site_id}&MemberID=#{member_id}&MemberPassString=#{member_pass_str}&TemplateNo=2"
    else
      @test_url = "https://pt01.mul-pay.jp/link/tshop00041183/Multi/Entry?ShopID=tshop00041183&OrderID=#{order_id}&Amount=5000&DateTime=#{date_time}&ShopPassString=#{shop_pass_str}&RetURL=http://localhost:3000/payments/payment_callback&UseCredit=1&JobCd=CHECK&SiteID=#{site_id}&MemberID=#{member_id}&MemberPassString=#{member_pass_str}"
    end
  end

  def payment_callback
    site_id = ENV["SITE_ID"]
    member_id = current_user.member_id
    site_pass = ENV["SITE_PASS"]
    shop_pass = ENV["SHOP_PASS"]
    date_time = l(DateTime.current, format: :to_gmo_pay_time)
    member_pass_str = Digest::MD5.hexdigest("#{site_id}|#{member_id}|#{params[:ShopID]}|#{params[:OrderID]}|#{site_pass}|#{shop_pass}|#{date_time}")
    if browser.device.mobile?
      url = "https://pt01.mul-pay.jp/link/tshop00041183/Member/Edit?SiteID=#{site_id}&MemberID=#{member_id}&ShopID=#{params[:ShopID]}&OrderID=#{params[:OrderID]}&MemberPassString=#{member_pass_str}&RetURL=#{registration_callback_url}&DateTime=#{date_time}&TemplateNo=2"
    else
      url = "https://pt01.mul-pay.jp/link/tshop00041183/Member/Edit?SiteID=#{site_id}&MemberID=#{member_id}&ShopID=#{params[:ShopID]}&OrderID=#{params[:OrderID]}&MemberPassString=#{member_pass_str}&RetURL=#{registration_callback_url}&DateTime=#{date_time}"
    end
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
    system_plan = SystemPlan.first
    order = Order.new(user_id: current_user.id, system_plan_id: system_plan.id, order_id: params[:OrderID])
    if order.save!
      current_user.calendars.first.update!(is_released: true)
      flash[:success] = "プラン登録が完了し、カレンダーを公開しました。"
      redirect_to user_calendar_dashboard_url(current_user, current_user.calendars.first)
    end
    # {"SiteID"=>"",
    #   "MemberID"=>"",
    #   "ShopID"=>"",
    #   "OrderID"=>"",
    #   "CheckString"=>"",
    #   "DateTime"=>"",
    #   "ErrCode"=>"",
    #   "ErrInfo"=>""}
  end

end
