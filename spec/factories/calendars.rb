FactoryBot.define do
    factory :calendar do
      calendar_name {"ひまわりマッサージ"}
      phone {"09057975695"}

        after(:create) do |calendar|
            1.times do
                create(:staff, calendar: calendar)
                create(:task_course, calendar: calendar)
                create(:calendar_config, calendar: calendar)
            end
        end
    end
end