class AddDefaultValue < ActiveRecord::Migration[6.1]
  def change
  	remove_column :admins, :status
  	add_column :admins, :status, :string, default: "available"
  end
end
