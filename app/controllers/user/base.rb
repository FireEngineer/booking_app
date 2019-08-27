class User::Base < ApplicationController
    layout 'user'

    def calendar
        calendar_params = params[:calendar_name] || params[:calendar_calendar_name]
        @calendar = Calendar.find_by(calendar_name: calendar_params)
        @q = Task.with_store_member.ransack(params[:q])
    end

end
