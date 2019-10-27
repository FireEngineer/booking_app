class Task < ApplicationRecord
  acts_as_paranoid
  validate :check_time_original
  validate :check_include_work_time
  validate :start_end_check
  validate :check_after_timenow
  validate :check_calendar_holiday

  belongs_to :task_course, optional: true
  belongs_to :store_member, optional: true
  belongs_to :calendar
  belongs_to :staff, optional: true

  scope :member_tasks, -> (store_member) { where(store_member_id: store_member.id) }
  scope :expect_past, -> { where("start_time >= ?", Time.current) }
  scope :future_tasks, -> { where("start_time >= ?", Time.current) }
  scope :staff_tasks, -> (staff) { where(staff_id: staff.id) }
  scope :staff_tasks, -> (staff) { where(staff_id: staff.id) }
  scope :today_tasks, -> { where("start_time >= ? && start_time <= ?", Time.current.beginning_of_day, Time.current.end_of_day) }
  scope :prev_task, -> { where("start_time < ?", Time.current.beginning_of_day) }
  scope :next_task, -> { where("start_time > ?", Time.current.end_of_day) }

  # after_create :sync_create, :mail_send
  # after_update :sybc_update, :line_send_with_edit_task, :mail_send_with_edit_task
  # after_destroy :sybc_delete, :line_send_with_delete_task, :mail_send_with_delete_task
  

  # 予約が被っている時刻に同時に保存されないように検証
  after_create do
    # lockメソッドを使って、DBのトランザクションレベルを変更
    interval_time = calendar.calendar_config.interval_time
    raise TaskUnuniqueError if Task.lock.where('start_time < ? && ? < end_time', end_time.since(interval_time.minutes), start_time.ago(interval_time.minutes)).where(staff_id: staff_id).where.not(id: id).any?
  end

  def self.register_unregistered_tasks_in_staff_google_calendar(staff)
    Task.future_tasks.staff_tasks(staff).each do |task|
      unless task.google_event_id
        SyncCalendarService.new(task, task.staff, task.calendar).create_event
      end
    end
  end
  
  def self.by_calendar(calendar)
    joins(:store_member).where(calendar_id: calendar.id).select('tasks.*, store_members.name, store_members.email, store_members.phone, store_members.id as member_id')
  end

  def calendar_event_uid
    unique_id = "#{self.staff.calendar.public_uid}todo#{self.id}"
    Modules::Base32.encode32hex(unique_id).gsub('=', '')
  end

  # バリデーション======================================================
  # 時間がかぶっていないかどうか
  def check_time_original
    interval_time = calendar.calendar_config.interval_time
    unless Task.where('start_time < ? && ? < end_time', end_time.since(interval_time.minutes), start_time.ago(interval_time.minutes))
               .where(staff_id: staff_id)
               .where.not(id: id)
               .empty?
      errors.add(:start_time, '予約時間が重複しています') # エラーメッセージ
    end
  end

  # 勤務時間内かどうか
  def check_include_work_time
    date = start_time.to_date
    staff = self.staff
    shift = staff.staff_shifts.find_by(work_date: date)
    unless start_time >= shift.work_start_time && end_time <= shift.work_end_time
      errors.add(:start_time, 'スタッフの勤務時間外です。') # エラーメッセージ
    end
    # 休憩時間に被っているかどうか検証
    shift.staff_rest_times.each do |rest|
      if start_time < rest.rest_end_time && end_time > rest.rest_start_time
        errors.add(:start_time, 'スタッフの勤務時間外です。') # エラーメッセージ
        return
      end
    end
  end

  # 開始時間が終了時間より遅くないか
  def start_end_check
    errors.add(:end_time, 'の時間を正しく記入してください。') unless
    start_time < end_time
  end

  # 予約時間が現時刻より先かどうか
  # 過去の予約時間の変更はできない、それ以外は許可
  def check_after_timenow
    if start_time < Time.current && (start_time_changed? || end_time_changed?)
      errors.add(:start_time, '現時刻より前の予定は作成できません。')
    end
  end

  # 休みの日かどうか
  def check_calendar_holiday
    day = %w[日 月 火 水 木 金 土][start_time.wday]
    if calendar.calendar_config.regular_holidays.where(holiday_flag: true).find_by(day: day) ||
       calendar.calendar_config.iregular_holidays.where('date >= ?', Date.current).find_by(date: start_time.to_date)
      errors.add(:start_time, 'この日は休みです。')
    end
  end

  private

  def sync_create
    SyncCalendarService.new(self, self.staff, self.calendar).create_event
  end

  def sybc_update
    SyncCalendarService.new(self, self.staff, self.calendar).update_event
  end

  def sybc_delete
    SyncCalendarService.new(self, self.staff, self.calendar).delete_event
  end

  def line_send_with_edit_task
    LineBot.new.push_message_with_edit_task(self, store_member.line_user_id) if store_member.line_user_id
  end

  def line_send_with_delete_task
    LineBot.new.push_message_with_delete_task(self, store_member.line_user_id) if store_member.line_user_id
  end

  def mail_send
    NotificationMailer.send_confirm_to_user(self, calendar.user, calendar).deliver
  end

  def mail_send_with_edit_task
    NotificationMailer.send_edit_task_to_user(self, calendar.user, calendar).deliver
  end

  def mail_send_with_delete_task
    NotificationMailer.send_delete_task_to_user(self, calendar.user, calendar).deliver
  end
end
