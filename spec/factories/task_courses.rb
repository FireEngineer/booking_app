FactoryBot.define do
    factory :task_course do
        title {"60分コース"}
        description {"60分コースです"}
        course_time {60}
        charge {5000}
    end
end