class ValidateTask

    attr_accessor :events, :time, :task_course

    def initialize(events, time, task_course)
        @events = events
        @time = time
        @task_course = task_course
    end

    def self.call(events, time, task_course)
        new(events, time, task_course).call
    end

    def call
        time_start = Time.zone.parse(time)
        time_end = time_start.since(task_course.course_time.to_i.minutes) 
        limit = calendar_config.capacity #予約可能件数
        count = 0
        events.each do |event|
            task_s = Time.zone.parse("#{event[0]}").ago(10.minutes)  
            task_e = Time.zone.parse("#{event[1]}").since(10.minutes) 
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

    def before_time
    end


end