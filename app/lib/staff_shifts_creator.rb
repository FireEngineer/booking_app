class StaffShiftsCreator
  attr_reader :start_term, :end_term, :staff

  def initialize(start_term, end_term, staff)
    @start_term = start_term
    @end_term = end_term
    @staff = staff
  end

  def self.call(start_term, end_term, staff)
    new(start_term, end_term, staff).call
  end

  # 指定された期間の日付ごとに、スタッフのシフトを作成している。
  def call
    [*start_term..end_term].each do |date|
      @staff.staff_shifts.build(work_date: date, work_start_time: start_time(date), work_end_time: end_time(date)).save
    end
  end

  private

  def holiday(date)
    day = %w[日 月 火 水 木 金 土][date.wday]
    @staff.staff_regular_holidays.find_by(day: day)
  end

  def start_time(date)
    Time.parse(date.to_s).change(hour: holiday(date).work_start_at.hour, min: holiday(date).work_start_at.min)
  end

  def end_time(date)
    Time.parse(date.to_s).change(hour: holiday(date).work_end_at.hour, min: holiday(date).work_end_at.min)
  end
end
