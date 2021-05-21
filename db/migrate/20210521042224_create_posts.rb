class CreatePosts < ActiveRecord::Migration[6.1]
  def change
    create_table :posts do |t|
      t.string :post
      t.string :status
      t.integer :user_id
      t.integer :coupon_id

      t.timestamps
    end
  end
end
