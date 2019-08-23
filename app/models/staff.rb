class Staff < ApplicationRecord
    belongs_to :calendar
    has_many :staff_shifts
end
