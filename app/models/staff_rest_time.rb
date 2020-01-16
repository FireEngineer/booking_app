class StaffRestTime < ApplicationRecord
  belongs_to :staff_shift

  validate :check_start_end_time
  validate :check_include_work_time
  validate :check_after_timenow
  validate :check_time_original

  def check_start_end_time
    if rest_start_time >= rest_end_time
      errors.add(:rest_end_time, '開始時間より早い時間に終了時間を設定することはできません。') # エラーメッセージ
    end
  end

  # 勤務時間内かどうか
  def check_include_work_time
    staff = staff_shift.staff
    shift = staff_shift
    if shift.is_holiday?
      errors.add(:work_start_time, 'スタッフの休日です。') # エラーメッセージ
      return
    end
    unless rest_start_time >= shift.work_start_time && rest_end_time <= shift.work_end_time
      errors.add(:work_start_time, 'スタッフの勤務時間外や、日付をまたいで休憩を設定できません。') # エラーメッセージ
      return
    end
    # 他の休憩時間に被っているかどうか検証
    shift.staff_rest_times.where.not(id: id).each do |rest|
      if rest_start_time < rest.rest_end_time && rest_end_time > rest.rest_start_time
        errors.add(:work_start_time, '休憩時間が重複しています。') # エラーメッセージ
        return
      end
    end
  end

  # 時間が現時刻より先かどうか
  def check_after_timenow
    errors.add(:work_start_time, '現時刻以前には休憩を設定できません。') if rest_start_time < Time.current
  end

  # 時間が予定とがかぶっていないかどうか
  def check_time_original
    staff = staff_shift.staff
    interval_time = staff.calendar.calendar_config.interval_time
    unless Task.lock.where('start_time < ? && ? < end_time', rest_end_time.since(interval_time.minutes), rest_start_time.ago(interval_time.minutes))
               .only_valid
               .where(staff_id: staff.id)
               .empty?
      errors.add(:work_start_time, '予約時間と重複しています') # エラーメッセージ
    end
  end
end
