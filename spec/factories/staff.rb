FactoryBot.define do
    factory :staff do
      name {"今井"}
      sequence(:email) { |n| "staff#{n}@gmail.com" }
      password {"password"}
      password_confirmation {"password"}

      after(:create) do |staff|
        create(:staff_regular_holiday_sun, staff: staff)
        create(:staff_regular_holiday_mon, staff: staff)
        create(:staff_regular_holiday_tue, staff: staff)
        create(:staff_regular_holiday_wed, staff: staff)
        create(:staff_regular_holiday_thu, staff: staff)
        create(:staff_regular_holiday_fri, staff: staff)
        create(:staff_regular_holiday_sat, staff: staff)
      end

    end
end