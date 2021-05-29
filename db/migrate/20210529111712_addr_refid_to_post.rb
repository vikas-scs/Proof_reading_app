class AddrRefidToPost < ActiveRecord::Migration[6.1]
  def change
  	add_column :posts, :ref_id ,:integer
  end
end
