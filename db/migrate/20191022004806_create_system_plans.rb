class CreateSystemPlans < ActiveRecord::Migration[5.2]
  def change
    create_table :system_plans do |t|
      t.string :title
      t.string :plan_id
      t.integer :charge
      t.text :description

      t.timestamps
    end
  end
end
