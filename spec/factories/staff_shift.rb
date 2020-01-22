FactoryBot.define do
  factory :staff_shift do
    sequence(:work_start_time) { |n| DateTime.current.days_since(n).change(hour: 8, min: 0o0) }
    sequence(:work_end_time) { |n| DateTime.current.days_since(n).change(hour: 20, min: 0o0) }
    sequence(:work_date) { |n| Date.current.days_since(n) }
    is_holiday { false }
  end
end
