class Calendar < ApplicationRecord
  belongs_to :user
  has_many :tasks
  has_one :line_bot
  accepts_nested_attributes_for :line_bot, allow_destroy: true

  validates :calendar_name, uniqueness: true

  def to_param
    calendar_name
  end

end
