class CreateOrderPlans < ActiveRecord::Migration[5.2]
  def change
    create_table :order_plans do |t|
      t.string :order_id
      t.references :user, foreign_key: true
      t.references :plan, foreign_key: true

      t.timestamps
    end
  end
end
