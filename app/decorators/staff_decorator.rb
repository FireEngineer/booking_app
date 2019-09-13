module StaffDecorator
  def active_display(staff)
    'active' if self == staff
  end
end
