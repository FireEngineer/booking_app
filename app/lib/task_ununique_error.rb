class TaskUnuniqueError < StandardError

    attr_reader :task

    def initialize(task)
        @task = task
    end

    def new(task)
        
    end

end