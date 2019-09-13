class User::IregularHolidaysController < User::Base
  before_action :calendar
  before_action :iregular_holiday, only: %i[edit update destroy]

  def index
    @json_data = json_data
    @regular_holiday = calendar_config.regular_holidays
  end

  def new
    @iregular_holiday = IregularHoliday.new(calendar_config_id: calendar_config.id, date: params[:date])
  end

  def create
    @iregular_holiday = IregularHoliday.new(iregular_holiday_params)
    @iregular_holiday.calendar_config = calendar_config
    if @iregular_holiday.save
      flash[:success] = '休日を作成しました'
      redirect_to calendar_iregular_holidays_path(@calendar)
    else
      if @iregular_holiday.errors
        @iregular_holiday.errors.full_messages.each do |msg|
          flash[:danger] = msg
        end
      else
        flash[:danger] = '休日を作成できませんでした'
      end
      redirect_to calendar_iregular_holidays_path(@calendar)
    end
  end

  def edit; end

  def update
    if @iregular_holiday.update(iregular_holiday_params)
      flash[:success] = '休日を更新しました'
      redirect_to calendar_iregular_holidays_path(@calendar)
    else
      if @iregular_holiday.errors
        @iregular_holiday.errors.full_messages.each do |msg|
          flash[:danger] = msg
        end
      else
        flash[:danger] = '休日を更新できませんでした'
      end
      redirect_to calendar_iregular_holidays_path(@calendar)
    end
  end

  def destroy
    if @iregular_holiday.destroy
      flash[:success] = '休日を削除しました'
      redirect_to calendar_iregular_holidays_path(@calendar)
    else
      flash[:danger] = '休日を削除できませんでした'
      redirect_to calendar_iregular_holidays_path(@calendar)
    end
  end

  private

  def iregular_holiday_params
    params.require(:iregular_holiday).permit(:date, :description, :id, :calendar_config_id)
  end

  def calendar_config
    @calendar_config = @calendar.calendar_config
  end

  def iregular_holiday
    @iregular_holiday = IregularHoliday.find(params[:id])
  end

  def regular_holidays
    regular_holidays = calendar_config.regular_holidays.where(holiday_flag: true)
    a = begin
            [*Date.current.beginning_of_month..Date.current.since(6.months).end_of_month].map do |date|
              day = %w[日 月 火 水 木 金 土][date.wday]
              if regular_holidays.find_by(day: day)
                {
                  start: l(date, format: :to_json),
                  end: l(date.tomorrow, format: :to_json),
                  overlap: false,
                  rendering: 'background'
                }
              else
                {

                }
              end
            end
        rescue StandardError
          nil
          end
  end

  def iregular_holidays
    calendar_config.iregular_holidays.map do |date|
      {
        title: '休日',
        start: l(date.date, format: :to_json),
        end: l(date.date.tomorrow, format: :to_json),
        overlap: false,
        id: date.id
        # rendering: 'background'
      }
    end
  end

  def staff_shifts(staff)
    staff.staff_shifts.map do |shift|
      {
        start: l(shift.work_start_time, format: :to_work_json),
        end: l(shift.work_end_time, format: :to_work_json),
        rendering: 'background'
      }
    end
  rescue StandardError
    nil
  end

  def json_data
    hash = {
      "start_date": Date.current.beginning_of_month,
      "end_date": Date.current.since(6.months).end_of_month,
      "holidays": regular_holidays + iregular_holidays
    }.to_json
  end
end
