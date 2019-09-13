class StoreMember < ApplicationRecord
  belongs_to :calendar
  has_many :tasks
  # validates_associated :tasks
  accepts_nested_attributes_for :tasks, allow_destroy: true
end
