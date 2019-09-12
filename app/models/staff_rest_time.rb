class StaffRestTime < ApplicationRecord
    belongs_to :staff_shift

    validate :check_start_end_time
    validate :check_include_work_time
    validate :check_after_timenow
    validate :check_time_original

    def check_start_end_time
        if self.rest_start_time >= self.rest_end_time
            errors.add(:rest_end_time, "開始時間より早い時間に終了時間を設定することはできません。") # エラーメッセージ
        end
    end

    # 勤務時間内かどうか
    def check_include_work_time
        staff = self.staff_shift.staff
        shift = self.staff_shift
        if shift.is_holiday?
            errors.add(:start_time, "スタッフの休日です。") # エラーメッセージ
            return
        end
        if !(self.rest_start_time >= shift.work_start_time && self.rest_end_time <= shift.work_end_time)
            errors.add(:start_time, "スタッフの勤務時間外です。") # エラーメッセージ
            return
        end
        # 他の休憩時間に被っているかどうか検証
        shift.staff_rest_times.each do |rest|
            if (self.rest_start_time < rest.rest_end_time && self.rest_end_time > rest.rest_start_time)
                errors.add(:start_time, "休憩時間が重複しています。") # エラーメッセージ
                return
            end
        end
    end

    # 時間が現時刻より先かどうか
    def check_after_timenow
        if self.rest_start_time < Time.current
            errors.add(:start_time, "現時刻以前には休憩を設定できません。")
        end
    end

    # 時間予定とがかぶっていないかどうか
    def check_time_original
        staff = self.staff_shift.staff
        interval_time = staff.calendar.calendar_config.interval_time
        unless Task.where("start_time < ? && ? < end_time", self.rest_end_time.since(interval_time.minutes), self.rest_start_time.ago(interval_time.minutes))
                .where(staff_id: staff.id)
                .empty?
            errors.add(:start_time, "予約時間と重複しています") # エラーメッセージ
        end
    end
end
