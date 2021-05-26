class Addcoupon < ActiveRecord::Migration[6.1]
  def change
  	add_column :posts, :cupon_id, :integer
  end
end
