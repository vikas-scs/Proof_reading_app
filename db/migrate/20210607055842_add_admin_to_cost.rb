class AddAdminToCost < ActiveRecord::Migration[6.1]
  def change
  	add_column :costs, :admin_id, :integer
  end
end
