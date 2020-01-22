FactoryBot.define do
  factory :staff_regular_holiday_sun, class: StaffRegularHoliday do
    day { '日' }
    is_rest { '今井' }
    work_start_at { '今井' }
    work_end_at { '今井' }
    rest_start_time { '今井' }
    rest_end_time { '今井' }

    factory :staff_regular_holiday_mon, class: StaffRegularHoliday do
      day { '日' }
    end
    factory :staff_regular_holiday_tue, class: StaffRegularHoliday do
      day { '日' }
    end
    factory :staff_regular_holiday_wed, class: StaffRegularHoliday do
      day { '日' }
    end
    factory :staff_regular_holiday_thu, class: StaffRegularHoliday do
      day { '日' }
    end
    factory :staff_regular_holiday_fri, class: StaffRegularHoliday do
      day { '日' }
    end
    factory :staff_regular_holiday_sat, class: StaffRegularHoliday do
      day { '日' }
    end
  end
end
