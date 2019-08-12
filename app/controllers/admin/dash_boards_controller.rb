class Admin::DashBoardsController < Admin::Base
    def top
        @admin = Admin.find(params[:id])
    end
end
