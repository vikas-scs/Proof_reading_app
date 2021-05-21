class AddFileldsToAdmin < ActiveRecord::Migration[6.1]
  def change
  	add_column :admins, :role, :string
  	add_column :admins, :status, :string
  end
end
