class Staff::StaffsController < User::Base
  before_action :calendar

  def show
    @staff = Staff.find(params[:id])
  end

end
