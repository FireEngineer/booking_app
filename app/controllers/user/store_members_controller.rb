class User::StoreMembersController < User::Base
  before_action :calendar

  def index
    @store_members = @calendar.store_members
  end

  def show
    @store_member = StoreMember.find(params[:id])
    @tasks = @store_member.tasks.order(start_time: "desc")
  end

  def store_member_task_show
    @task = Task.find(params[:id])
  end
end
