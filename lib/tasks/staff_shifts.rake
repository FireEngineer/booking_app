namespace :staff_shifts do
  desc 'スタッフタスク作成'
  task create: :environment do
    # 翌日のタスクを検索して、リマインド通知
    Staff.all.each do |staff|
      desplay_week_term = staff.calendar.display_week_term
      start_term = Date.current.beginning_of_month
      end_term = Date.current.weeks_since(desplay_week_term + 1).end_of_month
      last_shift = staff.staff_shifts.order(:work_date).last
      StaffShiftsCreator.call(start_term, end_term, staff)
    end
    puts "スタッフシスト作成 rails task"
  end
end
