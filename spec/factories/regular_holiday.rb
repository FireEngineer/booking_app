FactoryBot.define do
    factory :regular_holiday do
        day {"月"}
        holiday_flag {false}
        business_start_at {Time.current.change(hour: 10, min: 00)}
        business_end_at {Time.current.change(hour: 22, min: 00)}
        is_rest {false}
        rest_start_time {Time.current.change(hour: 10, min: 00)}
        rest_end_time {Time.current.change(hour: 22, min: 00)}
    end
end