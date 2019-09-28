FactoryBot.define do
    factory :staff do
      name {"今井"}
      sequence(:email) { |n| "staff#{n}@gmail.com" }
      password {"password"}
      password_confirmation {"password"}

      after(:create) do |staff|
        create(:staff_regular_holiday_sun, staff: staff, regular_holiday: staff.calendar.calendar_config.regular_holidays.find_by(day: "日"))
        create(:staff_regular_holiday_mon, staff: staff, regular_holiday: staff.calendar.calendar_config.regular_holidays.find_by(day: "月"))
        create(:staff_regular_holiday_tue, staff: staff, regular_holiday: staff.calendar.calendar_config.regular_holidays.find_by(day: "火"))
        create(:staff_regular_holiday_wed, staff: staff, regular_holiday: staff.calendar.calendar_config.regular_holidays.find_by(day: "水"))
        create(:staff_regular_holiday_thu, staff: staff, regular_holiday: staff.calendar.calendar_config.regular_holidays.find_by(day: "木"))
        create(:staff_regular_holiday_fri, staff: staff, regular_holiday: staff.calendar.calendar_config.regular_holidays.find_by(day: "金"))
        create(:staff_regular_holiday_sat, staff: staff, regular_holiday: staff.calendar.calendar_config.regular_holidays.find_by(day: "土"))

        # create_list(:staff_shift, 90, staff: staff)
      end
    end
end