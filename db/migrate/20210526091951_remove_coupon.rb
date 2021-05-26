class RemoveCoupon < ActiveRecord::Migration[6.1]
  def change
  	remove_column :posts, :coupon_id
  end
end
