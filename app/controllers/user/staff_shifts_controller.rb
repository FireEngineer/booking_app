class User::StaffShiftsController < User::Base
  before_action :set_staff_shift, only: [:edit, :update, :destroy]
  before_action :set_staff, only: [:index, :edit, :update, :destroy]
  before_action :set_calendar, only: [:index, :edit, :update, :destroy]

  # GET /user/staff_shifts
  # GET /user/staff_shifts.json
  def index
    @month = params[:month]&.to_datetime || DateTime.current
    @staff_shifts = @staff.staff_shifts.where(work_date: @month.all_month)
    start_of_month = @month.beginning_of_month
    end_of_month = @month.end_of_month
    unless @staff_shifts.find_by(work_date: start_of_month)
      [*start_of_month..end_of_month].each do |date|
        start_time = Time.parse("#{date}").since(10.hours).since(0.minutes)
        end_time = start_time.since(8.hours).since(0.minutes)
        @staff.staff_shifts.build(work_date: date, work_start_time: start_time, work_end_time: end_time).save
      rescue
        puts "エラー"
      end
    end
  end

  def edit
    
  end

  # PATCH/PUT /user/staff_shifts/1
  # PATCH/PUT /user/staff_shifts/1.json
  def update
    respond_to do |format|
      if @staff_shift.update(staff_shift_params)
        format.html { redirect_to calendar_staff_staff_shifts_url(@calendar, @staff), notice: 'シフトを更新しました。' }
        format.json { render :show, status: :ok, location: @staff_shift }
      else
        format.html { redirect_to calendar_staff_staff_shifts_url(@calendar, @staff), notice: 'シフトを更新できませんでした。' }
        format.json { render json: @staff_shift.errors, status: :unprocessable_entity }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_staff_shift
      @staff_shift = StaffShift.find(params[:id])
    end

    def set_staff
      @staff = Staff.find(params[:staff_id])
    end

    def set_calendar
      @calendar = Calendar.find_by(calendar_name: params[:calendar_calendar_name])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def staff_shift_params
      params.require(:staff_shift).permit(:work_start_time, :work_end_time, :staff_id)
    end

end
