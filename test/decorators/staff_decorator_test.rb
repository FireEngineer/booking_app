require 'test_helper'

class StaffDecoratorTest < ActiveSupport::TestCase
  def setup
    @staff = Staff.new.extend StaffDecorator
  end

  # test "the truth" do
  #   assert true
  # end
end
