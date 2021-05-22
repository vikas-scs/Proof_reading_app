class CreateCoupons < ActiveRecord::Migration[6.1]
  def change
    create_table :coupons do |t|
      t.string :coupon_code
      t.float :amount
      t.float :percentage
      t.integer :coupon_usage_count

      t.timestamps
    end
  end
end
