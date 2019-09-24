module StaffDecorator
  def active_display(staff)
    'active' if self == staff
  end

  def line_link
    if line_user_id
      "LINE連携済み"
    else
      "LINE未連携"
    end
  end

end
