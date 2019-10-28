class SystemPlan < ApplicationRecord
  has_many :orders
  has_many :users, through: :orders

  validates :title, presence: true
  validates :plan_id, presence: true, uniqueness: true
  validates :charge, presence: true
end
