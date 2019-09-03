require 'test_helper'

class StaffRegularHolidayDecoratorTest < ActiveSupport::TestCase
  def setup
    @staff_regular_holiday = StaffRegularHoliday.new.extend StaffRegularHolidayDecorator
  end

  # test "the truth" do
  #   assert true
  # end
end
