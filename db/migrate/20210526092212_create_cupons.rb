class CreateCupons < ActiveRecord::Migration[6.1]
  def change
    create_table :cupons do |t|
      t.string :coupon_name
      t.float :amount
      t.float :percentage
      t.integer :usage_count

      t.timestamps
    end
  end
end
