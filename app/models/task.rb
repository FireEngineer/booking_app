class Task < ApplicationRecord
  # validates :title, :content, :due_at, presence: true
  # validates :start_time, uniqueness: true
  validate :check_time_original
  validate :check_include_work_time
  validate :start_end_check
  validate :check_after_timenow
  belongs_to :task_course
  belongs_to :store_member
  belongs_to :calendar
  belongs_to :staff

  after_save :sync_create, :line_send, :mail_send
  after_update :sybc_update, :line_send_with_edit_task
  after_destroy :sybc_delete, :line_send_with_delete_task

  def self.with_store_member
    joins(:store_member).select('tasks.*, store_members.name, store_members.email, store_members.phone, store_members.id as member_id')
  end

  def calendar_event_uid
    unique_id = "#{self.calendar.user.id}todo#{self.id}"
    Modules::Base32.encode32hex(unique_id).gsub("=","")
  end

  # バリデーション======================================================
  # 時間がかぶっていないかどうか
  def check_time_original
    before_time = self.calendar.calendar_config.before_time
    after_time = self.calendar.calendar_config.after_time
    unless Task.where("start_time < ?", self.end_time.since(before_time.minutes))
                .where("end_time > ?", self.start_time.ago(after_time.minutes))
                .where(staff_id: self.staff_id)
                .where.not(id: self.id)
                .empty?
      errors.add(:start_time, "予約時間が重複しています") # エラーメッセージ
    end
  end

  # 勤務時間内かどうか
  def check_include_work_time
    date = self.start_time.to_date
    staff = self.staff
    shift = staff.staff_shifts.find_by(work_date: date)
    unless self.start_time >= shift.work_start_time && self.end_time <= shift.work_end_time
      errors.add(:start_time, "スタッフの勤務時間外です。") # エラーメッセージ
    end
  end

  # 開始時間が終了時間より遅くないか
  def start_end_check
    errors.add(:end_date, "の時間を正しく記入してください。") unless
    self.start_time < self.end_time
  end

  def check_after_timenow
    if self.start_time < Time.current
      errors.add(:start_time, "現時刻より前の予定は作成できません。")
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
      LineBot.new().push_message(self, self.store_member.line_user_id)
  rescue
    false
  end

  def line_send_with_edit_task
    if self.store_member.line_user_id
      LineBot.new().push_message_with_edit_task(self, self.store_member.line_user_id)
    end
  end

  def line_send_with_delete_task
    if self.store_member.line_user_id
      LineBot.new().push_message_with_delete_task(self, self.store_member.line_user_id)
    end
  end

  def mail_send
    NotificationMailer.send_confirm_to_user(self, self.calendar.user, self.calendar).deliver
  end

  def mail_send_with_edit_task
    NotificationMailer.send_confirm_to_user(self, self.calendar.user, self.calendar).deliver
  end
end
