class User::UserTasksController < User::Base
    def index
        @calendars = current_user.calendars
    end
end