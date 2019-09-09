class StaffShift < ApplicationRecord
  belongs_to :staff
  has_many :staff_rest_times
end
