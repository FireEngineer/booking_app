class TaskBroadcastJob < ApplicationJob
  queue_as :default

  def perform(task)
    puts "TaskBroadcastJob : #{task.created_at}"
    ActionCable.server.broadcast "task_channel_#{task.calendar.user.id}", user_id: task.calendar.user.id
  end
end
