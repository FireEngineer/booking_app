class ValidateTask

    attr_accessor :tasks, :time, :task_course

    def initialize(tasks, time, task_course)
        @tasks = tasks
        @time = time
        @task_course = task_course
    end

    def self.call(tasks, time, task_course)
        new(tasks, time, task_course).call
    end

    def call
        time_start = Time.zone.parse(time)
        time_end = time_start.since(task_course.course_time.to_i.minutes) 
        limit = calendar_config.capacity #予約可能件数
        count = 0
        tasks.each do |task|
            task_s = Time.zone.parse("#{task[0]}")
            task_e = Time.zone.parse("#{task[1]}")
            if task_s < time_end && time_start < task_e
                count += 1
                return false if count >= limit
            end
        end
        true
    end

    private

    def calendar_config
        task_course.calendar.calendar_config
    end

end