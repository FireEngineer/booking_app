module StoreMemberDecorator
  def line_status
    if line_user_id
      "LINE連携済み"
    else
      "未連携"
    end
  end
end
