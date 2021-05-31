class AddCoupon < ActiveRecord::Migration[6.1]
  def change
  	add_column :posts, :coupon_benifit, :float
  end
end
