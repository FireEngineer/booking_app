class User::StaffShiftsController < User::Base
  before_action :set_user_staff_shift, only: [:show, :edit, :update, :destroy]

  # GET /user/staff_shifts
  # GET /user/staff_shifts.json
  def index
    @calendar = Calendar.find_by(calendar_name: params[:calendar_calendar_name])
    @staff = Staff.find(params[:staff_id])
    @staff_shifts = @staff.staff_shifts
    now = Date.current
    start_of_month = now.beginning_of_month
    end_of_month = now.end_of_month
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

  # GET /user/staff_shifts/1
  # GET /user/staff_shifts/1.json
  def show
  end

  # GET /user/staff_shifts/new
  def new
    # @user_staff_shift = User::StaffShift.new
  end

  # GET /user/staff_shifts/1/edit
  def edit
  end

  # POST /user/staff_shifts
  # POST /user/staff_shifts.json
  def create
    @user_staff_shift = User::StaffShift.new(user_staff_shift_params)

    respond_to do |format|
      if @user_staff_shift.save
        format.html { redirect_to @user_staff_shift, notice: 'Staff shift was successfully created.' }
        format.json { render :show, status: :created, location: @user_staff_shift }
      else
        format.html { render :new }
        format.json { render json: @user_staff_shift.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /user/staff_shifts/1
  # PATCH/PUT /user/staff_shifts/1.json
  def update
    respond_to do |format|
      if @user_staff_shift.update(user_staff_shift_params)
        format.html { redirect_to @user_staff_shift, notice: 'Staff shift was successfully updated.' }
        format.json { render :show, status: :ok, location: @user_staff_shift }
      else
        format.html { render :edit }
        format.json { render json: @user_staff_shift.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /user/staff_shifts/1
  # DELETE /user/staff_shifts/1.json
  def destroy
    @user_staff_shift.destroy
    respond_to do |format|
      format.html { redirect_to user_staff_shifts_url, notice: 'Staff shift was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user_staff_shift
      @user_staff_shift = User::StaffShift.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_staff_shift_params
      params.require(:user_staff_shift).permit(:work_start_time, :work_end_time, :staff_id)
    end
end
