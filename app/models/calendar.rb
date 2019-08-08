class Calendar < ApplicationRecord
  belongs_to :user
  has_many :tasks
  has_many :task_courses
  has_one :line_bot
  accepts_nested_attributes_for :line_bot, allow_destroy: true

  validates :calendar_name, uniqueness: true

  after_create :create_default_task_course

  def to_param
    calendar_name
  end

  def create_default_task_course
    unless self.task_courses.first
      self.task_courses.build(title: "60分コース", description: "60分のコースになります。", course_time: 60).save
    end
  end

end
