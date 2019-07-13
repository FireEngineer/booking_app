class ConfigsController < ApplicationController

  def tasks_index
    @tasks = Task.where(user_id: params[:user_id])
  end


end
