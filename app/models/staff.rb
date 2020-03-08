class Staff < ApplicationRecord
  mount_uploader :picture, PictureUploader
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  acts_as_paranoid
  belongs_to :calendar
  has_many :staff_shifts, dependent: :destroy
  has_many :tasks
  has_many :staff_regular_holidays, dependent: :destroy
  accepts_nested_attributes_for :staff_regular_holidays

  after_create :create_staff_regular_holiday
  after_create :create_staff_shifts

  def create_staff_regular_holiday
    regular_holidays = get_regular_holidays
    get_regular_holidays.each do |holiday|
      staff_regular_holidays.build(day: holiday.day,
                                   work_start_at: holiday.business_start_at,
                                   work_end_at: holiday.business_end_at,
                                   regular_holiday_id: holiday.id,
                                   rest_start_time: holiday.rest_start_time,
                                   rest_end_time: holiday.rest_end_time).save
    end
  end

  def create_staff_shifts
    start_of_month = Date.current.beginning_of_month
    end_of_month = start_of_month.since(ENV['CALENDAR_DISPLAY_TERM'].to_i.months).end_of_month
    regular_holidays = get_regular_holidays
    [*start_of_month..end_of_month].each do |date|
      day = %w[日 月 火 水 木 金 土][date.wday]
      staff_regular_holiday = staff_regular_holidays.find_by(day: day)
      start_time = Time.parse(date.to_s).change(hour: staff_regular_holiday.work_start_at.hour, min: staff_regular_holiday.work_start_at.min)
      end_time = start_time.change(hour: staff_regular_holiday.work_end_at.hour, min: staff_regular_holiday.work_end_at.min)

      # 休憩フラグかtrueなら、休憩を作成
      if staff_regular_holiday.is_rest?
        shift = staff_shifts.build(work_date: date, work_start_time: start_time, work_end_time: end_time)
        shift.staff_rest_times.build(rest_start_time: start_time.change(hour: staff_regular_holiday.rest_start_time.hour),
                                     rest_end_time: end_time.change(hour: staff_regular_holiday.rest_end_time.hour)).save
      else
        shift = staff_shifts.build(work_date: date, work_start_time: start_time, work_end_time: end_time).save
      end
    end
  end

  def get_reservable_times(course, date)
    interval_time = self.calendar.calendar_config.interval_time
    staffs = Staff.where(id: self.id)
    staffs_google_tasks = StaffsScheduleOutputer.public_staff_private(staffs, [date])
    ok_term = StaffsScheduleOutputer.valid_shifts(staffs, date.all_day)
    not_term = StaffsScheduleOutputer.invalid_schedules(staffs, date.all_day, interval_time)
    time_interval(calendar).delete_if do |time|
      start_time = DateTime.parse(time(date, time))
      end_time = start_time.since((course.course_time + interval_time).minutes)
      !valid_schedule?(ok_term, not_term, staffs_google_tasks, start_time, end_time)
    end
  end

  private

  def get_regular_holidays
    regular_holidays = calendar.calendar_config.regular_holidays
  end

  # 予約カレンダーの表示間隔
  def time_interval(calendar)
    start_time = calendar.start_time
    end_time = calendar.end_time
    interval_time = calendar.display_interval_time
    array = []
    1.step do |i|
      array.push(Time.parse("#{start_time}:00") + interval_time.minutes * (i - 1))
      break if Time.parse("#{start_time}:00") + interval_time.minutes * (i - 1) == Time.parse("#{end_time}:00")
    end
    array
  end

  # 勤務時間内かどうか
  def valid_schedule?(ok_term, not_term, staffs_google_tasks, start_time, end_time)
    index = 0
    ok_term.zip(not_term).each do |ok_terms, not_terms|
      ok_flag = false
      not_flag = false
      ok_terms.each do |ok_term|
        if ok_term.first <= start_time && end_time <= ok_term.last
          ok_flag = true
        else
          not_flag = false
          break
        end
      end
      (not_terms + staffs_google_tasks[index]).each do |not_term|
        if not_term.any?
          if start_time < not_term.last && not_term.first < end_time
            not_flag = false
            break
          else
            not_flag = true
          end
        else
          not_flag = true
        end
        not_flag == true
      end
      return true if ok_flag == true && not_flag == true

      index += 1
    end
  end

  def time(date, time)
    puts time
    "#{date.year}-#{date.month}-#{date.day}T#{time.hour}:#{time.min}:00+09:00"
  end

end
