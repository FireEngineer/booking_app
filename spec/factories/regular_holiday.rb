FactoryBot.define do
  factory :regular_holiday_mon, class: RegularHoliday do
    day { '月' }
    holiday_flag { false }
    business_start_at { Time.current.change(hour: 10, min: 0o0) }
    business_end_at { Time.current.change(hour: 22, min: 0o0) }
    is_rest { false }
    rest_start_time { Time.current.change(hour: 10, min: 0o0) }
    rest_end_time { Time.current.change(hour: 22, min: 0o0) }

    factory :regular_holiday_tue, class: RegularHoliday do
      day { '火' }
    end
    factory :regular_holiday_wed, class: RegularHoliday do
      day { '水' }
    end
    factory :regular_holiday_thu, class: RegularHoliday do
      day { '木' }
    end
    factory :regular_holiday_fri, class: RegularHoliday do
      day { '金' }
    end
    factory :regular_holiday_sat, class: RegularHoliday do
      day { '土' }
    end
    factory :regular_holiday_sun, class: RegularHoliday do
      day { '日' }
    end
  end
end
