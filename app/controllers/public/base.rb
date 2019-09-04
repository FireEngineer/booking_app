class Public::Base < ApplicationController
    layout 'public'

    def calendar_is_released?
        calendar = Calendar.find_by(calendar_name: params[:calendar_calendar_name]) || Calendar.find_by(id: session[:calendar])
        unless calendar.is_released?
            redirect_to not_released_page_url
        end
    rescue
        redirect_to not_released_page_url
    end
end
