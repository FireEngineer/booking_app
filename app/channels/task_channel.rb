class TaskChannel < ApplicationCable::Channel
  def subscribed
    stream_from "task_channel_#{params[:user_id]}"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  def speak(data)
    puts "#{data["user_id"]}"
    ActionCable.server.broadcast "task_channel_#{data["user_id"]}", user_id: data
  end
end
