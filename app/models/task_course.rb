class TaskCourse < ApplicationRecord
  mount_uploader :picture, PictureUploader
  belongs_to :calendar
  has_many :tasks

  validates :title, presence: true
  validates :course_time, numericality: { greater_than: 0 }
  validates :charge, numericality: { greater_than_or_equal_to: 0 }

  def display_charge
    if is_tax_included? && is_more_than?
      "#{charge}円~(税込)"
    elsif is_tax_included? && !is_more_than?
      "#{charge}円(税込)"
    elsif !is_tax_included? && is_more_than?
      "#{charge}円〜(税別)"
    else
      "#{charge}円(税別)"
    end
  end

end
