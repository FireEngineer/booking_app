FactoryBot.define do
  factory :calendar_config do
    capacity { 1 }
    interval_time { 0 }
    cancelable_time { 24 }

    after(:create) do |calendar_config|
      create(:regular_holiday_sun, calendar_config: calendar_config)
      create(:regular_holiday_mon, calendar_config: calendar_config)
      create(:regular_holiday_tue, calendar_config: calendar_config)
      create(:regular_holiday_wed, calendar_config: calendar_config)
      create(:regular_holiday_thu, calendar_config: calendar_config)
      create(:regular_holiday_fri, calendar_config: calendar_config)
      create(:regular_holiday_sat, calendar_config: calendar_config)
    end
  end
end
