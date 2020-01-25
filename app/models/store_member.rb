class StoreMember < ApplicationRecord
  belongs_to :calendar
  has_many :tasks
  has_many :member_pictures, dependent: :destroy
  has_many :member_logs, dependent: :destroy
  # validates_associated :tasks
  accepts_nested_attributes_for :tasks, allow_destroy: true
end
