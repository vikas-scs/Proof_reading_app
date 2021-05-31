class AddDefaultValueToShowAttribute < ActiveRecord::Migration[6.1]
  def change
  	remove_column :admins, :wallet
  	add_column :admins, :wallet, :float, default: 0.0
  end
end
