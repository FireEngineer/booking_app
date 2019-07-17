class Task < ApplicationRecord
  # validates :title, :content, :due_at, presence: true
  validates :date_time, uniqueness: true
  belongs_to :user



  after_create :sync_create, :line_send, :mail_send
  after_update :sybc_update
  after_destroy :sybc_delete

  def calendar_event_uid
    unique_id = "#{self.user.id}todo#{self.id}"
    Modules::Base32.encode32hex(unique_id).gsub("=","")
  end

  private

  def sync_create
    SyncCalendarService.new(self,self.user).create_event
  end

  def sybc_update
    SyncCalendarService.new(self,self.user).update_event
  end

  def sybc_delete
    SyncCalendarService.new(self,self.user).delete_event
  end

  def line_send
    LineNotifyService.new(self,self.user).send
  end

  def mail_send
    NotificationMailer.send_confirm_to_user(self).deliver
  end
end
