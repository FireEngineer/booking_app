class Calendar < ApplicationRecord
  belongs_to :user
  has_many :store_member
  has_many :task_courses
  has_one :calendar_config
  has_many :tasks
  has_many :staffs
  

  validates :calendar_name, uniqueness: true

  after_create :create_default_task_course
  after_create :create_calendar_config

  def to_param
    calendar_name
  end

  def create_default_task_course
    unless self.task_courses.first
      self.task_courses.build(title: "60分コース", description: "60分のコースになります。", course_time: 60, charge: "5000").save
    end
  end

  def create_calendar_config
    unless self.calendar_config
      config = self.build_calendar_config(capacity: 1)
      array = ["日", "月", "火", "水", "木", "金", "土"]
      start_time = Time.current.change(hour: self.start_time, min: 0)
      end_time = Time.current.change(hour: self.end_time, min: 0)
      array.each do |day|
        config.regular_holidays.build(day: day, business_start_at: start_time, business_end_at: end_time)
      end
      config.save
    end
  end

end
