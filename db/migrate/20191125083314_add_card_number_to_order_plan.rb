class AddCardNumberToOrderPlan < ActiveRecord::Migration[5.2]
  def change
    add_column :order_plans, :card_number, :string
  end
end
