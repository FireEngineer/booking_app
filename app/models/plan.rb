class Plan < ApplicationRecord
  has_many :users, through: :order_plans
end
