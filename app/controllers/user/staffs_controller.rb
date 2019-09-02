class User::StaffsController < User::Base
  before_action :staff, only: %i(show edit update destroy)
  before_action :calendar

    def index
      @staffs = @calendar.staffs
    end

    def show
    end

    def new
      @staff = Staff.new()
    end

    def create
      @staff = @calendar.staffs.build(staff_params)
      if @staff.save
        flash[:success] = "スタッフを登録しました"
        redirect_to user_calendar_staffs_url(current_user, @calendar)
      else
        format.html { render :new }
        format.json { render json: @staff.errors, status: :unprocessable_entity }
      end
    end

    def edit
    end

    def update
      respond_to do |format|
        if @staff.update(staff_params)
          flash[:success] = "スタッフを更新しました"
          format.html { redirect_to user_calendar_staffs_url(current_user, @calendar) }
          # format.json { render :show, status: :ok, location: @staff }
        else
          flash[:danger] = "スタッフを更新できませんでした"
          format.html { redirect_to user_calendar_staffs_url(current_user, @calendar) }
          format.json { render json: @staff.errors, status: :unprocessable_entity }
        end
      end
    end

    def destroy
      @staff.destroy
      flash[:danger] = "スタッフを削除しました"
      redirect_to user_calendar_staffs_url(current_user, @calendar)
    end

    def staffs_shifts
      @staffs = @calendar.staffs
    end

    private
      def staff_params
        params.require(:staff).permit(:name)
      end

      def staff
        @staff = Staff.find(params[:id])
      end
end
