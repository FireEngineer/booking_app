class Plan < ApplicationRecord
  has_many :order_plans
  has_many :users, through: :order_plans
end
