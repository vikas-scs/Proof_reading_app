class AddInviteToStatement < ActiveRecord::Migration[6.1]
  def change
  	add_column :statements, :invite_id, :integer
  end
end
