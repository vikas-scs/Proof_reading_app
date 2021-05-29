class AddrRefidToStatement < ActiveRecord::Migration[6.1]
  def change
  	add_column :statements, :ref_id, :integer
  end
end
