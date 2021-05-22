class CreateCosts < ActiveRecord::Migration[6.1]
  def change
    create_table :costs do |t|
      t.float :word_cost
      t.float :admin_commission

      t.timestamps
    end
  end
end
