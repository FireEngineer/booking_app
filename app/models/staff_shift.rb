class StaffShift < ApplicationRecord
  belongs_to :staff
  has_many :staff_rest_times

  validate :same_date_with_staff

  def same_date_with_staff
    self.staff.staff_shifts.where.not(id: self.id).each do |shift|
      if self.work_date == shift.work_date
        errors.add(:work_date, '同じ日付のシフトが存在します') # エラーメッセージ
        return
      end
    end
  end
end
