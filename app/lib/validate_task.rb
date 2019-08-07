class ValidateTask

    attr_accessor :tasks, :time

    def initialize(tasks, time, calendar)
        @tasks = tasks
        @time = time
        @calendar = calendar
    end

    def self.call(tasks, time, calendar)
        new(tasks, time, calendar).call
    end

    def call
        time_start = Time.zone.parse(time)
        time_end = time_start.since(90.minutes) 
        limit = 3 #予約可能件数
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

    # def test
    #     puts @tasks
    #     puts @time
    #     puts @calendar
    # end

end