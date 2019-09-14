FactoryBot.define do
    factory :calendar_config do
        capacity {1}
        interval_time {0}
        cancelable_time {24}

        after(:create) do |calendar_config|
            7.times do
                create(:regular_holiday, calendar_config: calendar_config)
            end
        end
    end
end