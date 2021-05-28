class AddtimeToInvite < ActiveRecord::Migration[6.1]
  def change
  	add_column :invites, :time_taken, :string
  end
end
