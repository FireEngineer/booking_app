require 'rails_helper'

RSpec.describe Task, type: :model do
  before do
    # @user = create(:user)
    # @calendar = create(:calendar, user: @user)
    # @staff = create(:staff, calendar: @calendar)
    # @calendar.update(is_released: true)
    # @course = @calendar.task_courses.first
    # @store_member = create(:store_member, calendar: @calendar)
  end

    # 名前、メアド、パスワードがあれば有効であること
  it "is valid with a first_name, last_name, email, and password" do 
    # @task = Task.new( 
    #   request: "リクエスト",
    #   start_time: Time.current, 
    #   end_time: Time.current.since(1.hours), 
    #   task_course_id: @course,
    #   staff_id: @staff,
    #   store_member_id: @store_member,
    # )
    # expect(@task).to be_valid
  end

end
