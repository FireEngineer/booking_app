class Calendar < ApplicationRecord
  # gem "public_uid"でDBに保存される前にpublic_uidに8桁のランダムな文字列が付与される
  generate_public_uid

  belongs_to :user
  has_many :store_members
  has_many :task_courses
  has_one :calendar_config
  has_many :tasks
  has_many :staffs

  validates :display_week_term, presence: true
  validates :end_date, presence: true
  validates :start_date, presence: true
  validates :end_time, presence: true
  validates :start_time, presence: true

  after_create :create_default_task_course
  after_create :create_calendar_config


  def to_param
    public_uid
    # public_uid: params[:id]
    # public_uid
  end

  def create_default_task_course
    task_courses.build(title: '60分コース', description: '60分のコースになります。', course_time: 60, charge: '5000').save unless task_courses.first
  end

  def create_calendar_config
    unless calendar_config
      config = build_calendar_config(capacity: 1)
      array = %w[日 月 火 水 木 金 土]
      start_time = Time.current.change(hour: self.start_time, min: 0)
      end_time = Time.current.change(hour: self.end_time, min: 0)
      array.each do |day|
        config.regular_holidays.build(day: day, business_start_at: start_time, business_end_at: end_time, rest_start_time: start_time.change(hour: 12), rest_end_time: end_time.change(hour: 13))
      end
      config.save
    end
  end
  
end
