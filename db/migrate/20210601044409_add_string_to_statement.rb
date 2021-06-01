class AddStringToStatement < ActiveRecord::Migration[6.1]
  def change
  	remove_column :statements, :ref_id
  	add_column :statements, :ref_id, :string
  end
end
