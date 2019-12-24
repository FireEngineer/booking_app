class AddTrialDaysToPlans < ActiveRecord::Migration[5.2]
  def change
    add_column :plans, :trial_days, :integer, comment: "トライアル日数"
    add_column :plans, :billing_day, :integer, comment: "課金を開始する日（その月の何日から課金するかどうか）"
  end
end
