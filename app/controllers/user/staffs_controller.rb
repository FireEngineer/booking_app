class User::StaffsController < User::Base
    def index
      @calendar = Calendar.find_by(calendar_name: params[:calendar_calendar_name])
      @staffs = @calendar.staffs
    end

    def show
    end

    def new
      @calendar = Calendar.find_by(calendar_name: params[:calendar_calendar_name])
      @staff = Staff.new()
    end

    def create
      @calendar = Calendar.find_by(calendar_name: params[:calendar_calendar_name])
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
      @calendar = Calendar.find_by(calendar_name: params[:calendar_calendar_name])
      @staff = Staff.find(params[:id])
    end

    def update
      @calendar = Calendar.find_by(calendar_name: params[:calendar_calendar_name])
      @staff = Staff.find(params[:id])
      respond_to do |format|
        if @staff.update(staff_params)
          flash[:success] = "スタッフを登録しました"
          format.html { redirect_to user_calendar_staffs_url(current_user, @calendar) }
          # format.json { render :show, status: :ok, location: @staff }
        else
          flash[:danger] = "スタッフを更新しました"
          format.html { redirect_to user_calendar_staffs_url(current_user, @calendar) }
          format.json { render json: @staff.errors, status: :unprocessable_entity }
        end
      end
    end
      
      # DELETE /fruits/1
      # DELETE /fruits/1.json
    def destroy
      @calendar = Calendar.find_by(calendar_name: params[:calendar_calendar_name])
      @staff = Staff.find(params[:id])
      @staff.destroy
      flash[:danger] = "スタッフを削除しました"
      redirect_to user_calendar_staffs_url(current_user, @calendar)
    end
      
    private
      def staff_params
        params.require(:staff).permit(:name)
      end
end
