class User::CalendarConfigsController < User::Base
    before_action :calendar

    def update
        @calendar_config = Calendar.find_by(public_uid: params[:calendar_id]).calendar_config
        respond_to do |format|
            if @calendar_config.update(calendar_config_regular_holidays_params)
                format.html { redirect_to user_calendar_url(current_user, @calendar), notice: '詳細設定を更新しました。' }
            else
                format.html { redirect_to user_calendar_url(current_user, @calendar), notice: '詳細設定の更新に失敗しました。' }
            end
        end
    end

    private
    def calendar_config_regular_holidays_params
        params.require(:calendar_config).permit(:capacity, :interval_time, regular_holidays_attributes: [:holiday_flag, :id, :business_start_at, :business_end_at, :is_reset, :rest_start_time, :rest_end_time])
    end


end
