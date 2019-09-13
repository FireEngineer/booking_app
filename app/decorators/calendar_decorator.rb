module CalendarDecorator
  def display_release
    if is_released == true
      '公開中'
    else
      '非公開中'
    end
  end
end
