module TaskCourseDecorator
  def display_charge
    if is_tax_included? && is_more_than?
      "#{charge}円~(税込)"
    elsif is_tax_included? && !is_more_than?
      "#{charge}円(税込)"
    elsif !is_tax_included? && is_more_than?
      "#{charge}円〜(税別)"
    else
      "#{charge}円(税別)"
    end
  end
end
