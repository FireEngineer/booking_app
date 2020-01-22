class User::CalendarConfigsController < User::Base
  before_action :calendar

  def update
    @calendar_config = Calendar.find_by(public_uid: params[:calendar_id]).calendar_config
    respond_to do |format|
      if @calendar_config.update(calendar_config_regular_holidays_params)
        update_staff_regular_holiday if params[:all_staff_update] == 'true'
        format.html { redirect_to user_calendar_url(current_user, @calendar), notice: '詳細設定を更新しました。' }
      else
        format.html { redirect_to user_calendar_url(current_user, @calendar), notice: '詳細設定の更新に失敗しました。' }
      end
    end
  end

  private

  def calendar_config_regular_holidays_params
    params.require(:calendar_config).permit(:capacity, :interval_time, :booking_message, :booking_link, regular_holidays_attributes: %i[holiday_flag id business_start_at business_end_at is_rest rest_start_time rest_end_time])
  end

  def update_staff_regular_holiday
    @calendar_config.regular_holidays.each do |regular_holiday|
      regular_holiday.staff_regular_holidays.each do |holiday|
        holiday.update(is_holiday: regular_holiday.holiday_flag,
                       work_start_at: regular_holiday.business_start_at,
                       work_end_at: regular_holiday.business_end_at,
                       rest_start_time: regular_holiday.rest_start_time,
                       rest_end_time: regular_holiday.rest_end_time,
                       is_rest: regular_holiday.is_rest)
      end
    end
  end
end
