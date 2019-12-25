class AddPlanUidToPlans < ActiveRecord::Migration[5.2]
  def change
    add_column :plans, :plan_uid, :string, comment: "プランを識別するためのもの"
  end
end
