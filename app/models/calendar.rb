class Calendar < ApplicationRecord
  belongs_to :user
  has_many :tasks

  validates :calendar_name, uniqueness: true
end
