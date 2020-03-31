class LambdaFunction::Api::StaffShiftsController < ApplicationController
  protect_from_forgery with: :null_session

  def create
    staffs = Staff.all.each do |staff|
      desplay_month_term = ENV['CALENDAR_DISPLAY_TERM'].to_i
      start_term = Date.current.beginning_of_month
      end_term = Date.current.months_since(desplay_month_term + 1).end_of_month
      last_shift = staff.staff_shifts.order(:work_date).last
      StaffShiftsCreator.call(start_term, end_term, staff)
    end
    puts 'スタッフシスト作成 rails task'
    message = (staffs.any? ? "【シフト作成】スタッフ数：#{staffs.size}" : "【シフト作成】スタッフ数：0")
    LineBot.new.push_test(message)
    { statusCode: 200, body: JSON.generate('スタッフのシフト作成完了！') }
  end

  def test
    LineBot.new.push_test("テストシフト作成")
  end

  
end
