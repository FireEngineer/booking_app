class Public::Base < ApplicationController
    layout 'public'
    
    protect_from_forgery with: :exception

    # 例外に合わせたエラーハンドリング
    # 予約が同時にかぶった時に発動
    rescue_from TaskUnuniqueError, with: :handle_ununiqueness_task

    # 予約が同時にかぶった時に発動
    def handle_ununiqueness_task
        flash[:success] = '予約が重複しています。他の日にちをご指定ください。'
        calendar = Calendar.find_by(calendar_name: params["calendar_calendar_name"])
        redirect_to calendar_tasks_path(calendar)
    end



    def calendar_is_released?
        calendar = Calendar.find_by(calendar_name: params[:calendar_calendar_name]) || Calendar.find_by(id: session[:calendar])
        unless calendar.is_released?
            redirect_to not_released_page_url
        end
    rescue
        redirect_to not_released_page_url
    end
end
