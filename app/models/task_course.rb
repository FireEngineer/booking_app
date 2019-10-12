class TaskCourse < ApplicationRecord
  belongs_to :calendar
  has_many :tasks
  
  validates :title, presence: true
  validates :course_time, numericality: {greater_than: 0}
  validates :charge, numericality: {greater_than: 0}
end
