class Task < ApplicationRecord
  # validates :title, :content, :due_at, presence: true
  # validates :start_time, uniqueness: true
  validate :check_time_original
  belongs_to :task_course
  belongs_to :store_member
  belongs_to :calendar
  belongs_to :staff

  after_create :sync_create, :line_send, :mail_send
  after_update :sybc_update
  after_destroy :sybc_delete

  def self.with_store_member
    joins(:store_member).select('tasks.*, store_members.*')
  end

  def calendar_event_uid
    unique_id = "#{self.calendar.user.id}todo#{self.id}"
    Modules::Base32.encode32hex(unique_id).gsub("=","")
  end

  def check_time_original
    unless Task.where("start_time < ?", self.end_time)
                .where("end_time > ?", self.start_time)
                .where(staff_id: self.staff_id)
                .where.not(id: self.id)
                .empty?
      errors.add(:start_time, "予約時間が重複しています") # エラーメッセージ
    end
  end

  private

  def sync_create
    # SyncCalendarService.new(self, self.calendar.user, self.calendar).create_event
  end

  def sybc_update
    # SyncCalendarService.new(self, self.calendar.user, self.calendar).update_event
  end

  def sybc_delete
    # SyncCalendarService.new(self, self.calendar.user, self.calendar).delete_event
  end

  def line_send
    LineNotifyService.new(self, self.calendar.user, self.calendar).send
  end

  def mail_send
    NotificationMailer.send_confirm_to_user(self, self.calendar.user, self.calendar).deliver
  end
end
