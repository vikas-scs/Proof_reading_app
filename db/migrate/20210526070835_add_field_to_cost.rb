class AddFieldToCost < ActiveRecord::Migration[6.1]
  def change
  	add_column :costs, :fine_amount, :float
  end
end
