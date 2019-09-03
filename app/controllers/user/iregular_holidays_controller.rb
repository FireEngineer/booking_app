class User::IregularHolidaysController < User::Base
  before_action :calendar
  before_action :iregular_holiday, only: %i(edit update destroy)

  def index
    @json_data = json_data
    @regular_holiday = calendar_config.regular_holidays
  end
  
  def new
    @iregular_holiday = IregularHoliday.new(calendar_config_id: calendar_config.id)
  end

  def create
    @iregular_holiday = IregularHoliday.new(iregular_holiday_params)
    if @iregular_holiday.save
    else
    end
  end

  def edit

  end

  def update
    if @iregular_holiday.update(iregular_holiday_params)
    else
    end
  end

  def destroy
    if @iregular_holiday.destroy
    else
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
      a = [*Date.current.beginning_of_month..Date.current.since(6.months).end_of_month].map do |date|
        day = ["日", "月", "火", "水", "木", "金", "土"][date.wday]
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
      end rescue nil
    end


    def staff_shifts(staff)
      staff.staff_shifts.map do |shift|
        { 
          start: l(shift.work_start_time, format: :to_work_json),
          end: l(shift.work_end_time, format: :to_work_json),
          rendering: 'background' ,
        }
      end rescue nil
    end

    def json_data
      hash = {
       "start_date": Date.current.beginning_of_month,
       "end_date": Date.current.since(6.months).end_of_month,
       "holidays": regular_holidays,
      }.to_json
    end
end
