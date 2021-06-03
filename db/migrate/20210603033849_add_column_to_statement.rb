class AddColumnToStatement < ActiveRecord::Migration[6.1]
  def change
  	add_column :statements, :word_cost, :float
  end
end
