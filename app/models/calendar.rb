class Calendar < ApplicationRecord
  mount_uploader :picture, PictureUploader

  # gem "public_uid"でDBに保存される前にpublic_uidに8桁のランダムな文字列が付与される
  generate_public_uid

  belongs_to :user
  has_many :store_members
  has_many :task_courses
  has_one :calendar_config
  has_many :tasks
  has_many :staffs

  validates :display_interval_time, presence: true, numericality: { only_integer: true }
  validates :display_week_term, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 10 }
  validates :end_date, presence: true, numericality: { only_integer: true }
  validates :start_date, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 10 }
  validates :end_time, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 24 }
  validates :start_time, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 24 }

  validate :start_time_end_time_validate

  after_create :create_calendar_config

  def to_param
    public_uid
    # public_uid: params[:id]
    # public_uid
  end

  # def create_default_task_course
  #   task_courses.build(title: '60分コース', description: '60分のコースになります。', course_time: 60, charge: '5000').save unless task_courses.first
  # end

  def create_calendar_config
    unless calendar_config
      config = build_calendar_config(capacity: 1)
      config.booking_message = booking_message(self)
      array = %w[日 月 火 水 木 金 土]
      start_time = Time.current.change(hour: self.start_time, min: 0)
      end_time = Time.current.change(hour: self.end_time, min: 0)
      array.each do |day|
        config.regular_holidays.build(day: day, business_start_at: start_time, business_end_at: end_time, rest_start_time: start_time.change(hour: 12), rest_end_time: end_time.change(hour: 13))
      end
      config.save
    end
  end

  def iregular_holidays(term)
    calendar_config.iregular_holidays.where(date: term).map(&:date)
  end

  def regular_holiday_days
    calendar_config.regular_holidays.where(holiday_flag: true).map(&:day)
  end

  private

  def start_time_end_time_validate
    if start_time >= end_time
      errors.add(:start_time, 'は表示終了時刻より遅い時間には設定できません') # エラーメッセージ
    end
  end

  def booking_message(calendar)
    text = <<-EOS
        ご予約ありがとうございます！
        #{calendar.calendar_name}
    EOS
  end
end
