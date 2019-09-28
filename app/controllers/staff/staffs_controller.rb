class Staff::StaffsController < Staff::StaffBase
  before_action :calendar

  def show
    @staff = Staff.find(params[:id])
  end

end
