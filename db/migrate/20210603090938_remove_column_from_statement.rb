class RemoveColumnFromStatement < ActiveRecord::Migration[6.1]
  def change
  	remove_column :statements, :admin_commmission
  end
end
