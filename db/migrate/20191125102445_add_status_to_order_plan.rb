class AddStatusToOrderPlan < ActiveRecord::Migration[5.2]
  def change
    add_column :order_plans, :status, :integer, default: 0, comment: "決済プランのステータス"
  end
end
