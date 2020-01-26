class MemberLog < ApplicationRecord
  belongs_to :store_member
  has_many :log_pictures, dependent: :destroy
  accepts_nested_attributes_for :log_pictures, allow_destroy: true
end
