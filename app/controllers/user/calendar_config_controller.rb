class User::CalendarConfigController < ApplicationController

    def edit
    end

    def update
    end

    private
    def calendar_config_regular_holidays_params
        params.require(:calendar_config).permit()
    end

end
