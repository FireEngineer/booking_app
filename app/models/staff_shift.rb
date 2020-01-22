class StaffShift < ApplicationRecord
  belongs_to :staff
  has_many :staff_rest_times

  validate :same_date_with_staff

  scope :without_rest_date, -> { where.not(is_holiday: true) }

  def same_date_with_staff
    staff.staff_shifts.where.not(id: id).each do |shift|
      if work_date == shift.work_date
        errors.add(:work_date, '同じ日付のシフトが存在します') # エラーメッセージ
        return
      end
    end
  end
end
