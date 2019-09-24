class Staff::LineLinksController < User::Base
  before_action :calendar, except: [:line_link_staff]

  CHANNEL_ID = ENV['LINE_LOGIN_CHANNEL_ID']
  CHANNEL_SECRET = ENV['LINE_LOGIN_CHANNEL_SECRET']

  def redirect_line
    @user = @calendar.user
    @staff = Staff.find(params[:staff_id])
    # セッションにフォーム値を保持して、ラインログイン後レコード保存
    session[:staff_id] = @staff.id
    redirect_uri = URI.escape(line_link_staff_url)
    state = SecureRandom.base64(10)
    # このURLがラインログインへのURL
    url = LineAccess.redirect_url(CHANNEL_ID, redirect_uri, state)
    redirect_to url
  end

  def line_link_staff
    staff = Staff.find(session[:staff_id])
    calendar = staff.calendar
    # アクセストークンを取得
    get_access_token = LineAccess.get_access_token(CHANNEL_ID, CHANNEL_SECRET, params[:code])
    # アクセストークンを使用して、BOTとお客との友達関係を取得
    friend_response = LineAccess.get_friend_relation(get_access_token['access_token'])
    # アクセストークンのIDトークンを"gem jwt"を利用してデコード
    line_user_id = LineAccess.decode_response(get_access_token)

    # BOTと友達かどうか確認する。
    if friend_response['friendFlag'] == true
      if staff.update(line_user_id: line_user_id)
        flash[:success] = "LINE連携が成功しました"
        redirect_to calendar_staff_url(calendar, staff)
      else
        flash[:danger] = "LINE連携が失敗しました"
        redirect_to calendar_staff_url(calendar, staff)
      end
    else # ラインログインでボットと友達にならなかった時の処理
      flash[:danger] = 'ラインボットと友達になってください'
      redirect_to calendar_staff_url(calendar, staff)
      return
    end

  rescue
    flash[:danger] = 'ライン連携に失敗しました'
    redirect_to calendar_staff_url(calendar, staff)
  end

end
