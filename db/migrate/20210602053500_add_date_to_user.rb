class AddDateToUser < ActiveRecord::Migration[6.1]
  def change
  	add_column :posts, :cupon_date, :date
  end
end
