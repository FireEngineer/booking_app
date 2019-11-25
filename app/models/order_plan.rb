class OrderPlan < ApplicationRecord
  belongs_to :user
  belongs_to :plan

  enum status: {
    ongoing: 0,
    destroy: 1,
    cancel: 2,
  }, _prefix: true
end
