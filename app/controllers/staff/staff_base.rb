class Staff::StaffBase < User::Base
  skip_before_action :authenticate_current_user!
end
