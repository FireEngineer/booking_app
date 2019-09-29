module StaffDecorator
  def active_display(staff)
    'active' if self == staff
  end

  def line_link
    if line_user_id
      "<span class='badge badge-success'>LINE連携済み</span>".html_safe
    else
      "<span class='badge badge-secondary'>LINE未連携</span>".html_safe
    end
  end

end
