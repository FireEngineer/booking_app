class CreatePlans < ActiveRecord::Migration[5.2]
  def change
    create_table :plans do |t|
      t.string :title
      t.integer :charge
      t.text :description
      t.string :plan_id

      t.timestamps
    end
  end
end
