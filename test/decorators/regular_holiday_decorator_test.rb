require 'test_helper'

class RegularHolidayDecoratorTest < ActiveSupport::TestCase
  def setup
    @regular_holiday = RegularHoliday.new.extend RegularHolidayDecorator
  end

  # test "the truth" do
  #   assert true
  # end
end
