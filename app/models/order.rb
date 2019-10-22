class Order < ApplicationRecord
  belongs_to :user
  belongs_to :system_plan

  validates :order_id, presence: true, uniqueness: true
end
