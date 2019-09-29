class Staff::StaffsController < Staff::StaffBase
  before_action :calendar
  before_action :staff

  def show
  end

  def password_edit

  end

  def update
    if params[:staff][:password].blank?
      params[:staff].delete("password")
      params[:staff].delete("password_confirmation")
    end
    if @staff.update(staff_params)
      sign_in(@staff, :bypass => true)
      flash[:success] = "スタッフ情報を更新しました"
      redirect_to calendar_staff_url(@calendar, @staff)
    else
      render :show
    end
  end

  private
    def staff_params
      params.require(:staff).permit(:name, :email, :password, :password_confirmation, :description)
    end

    def staff
      @staff = @calendar.staffs.find(params[:id])
    end

end
