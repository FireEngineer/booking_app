class TaskCourse < ApplicationRecord
  mount_uploader :picture, PictureUploader
  belongs_to :calendar
  has_many :tasks
  
  validates :title, presence: true
  validates :course_time, numericality: {greater_than: 0}
  validates :charge, numericality: {greater_than_or_equal_to: 0}
end
