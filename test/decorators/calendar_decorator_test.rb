require 'test_helper'

class CalendarDecoratorTest < ActiveSupport::TestCase
  def setup
    @calendar = Calendar.new.extend CalendarDecorator
  end

  # test "the truth" do
  #   assert true
  # end
end
