namespace :staff_shifts do
  desc 'スタッフタスク作成'
  task create: :environment do
    Staff.all.each do |staff|
      desplay_month_term = ENV['CALENDAR_DISPLAY_TERM'].to_i
      start_term = Date.current.beginning_of_month
      end_term = Date.current.months_since(desplay_month_term + 1).end_of_month
      last_shift = staff.staff_shifts.order(:work_date).last
      StaffShiftsCreator.call(start_term, end_term, staff)
    end
    puts 'スタッフシスト作成 rails task'
  end
end
