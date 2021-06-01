class AddExpireyToCupon < ActiveRecord::Migration[6.1]
  def change
  	add_column :cupons, :expired_date, :date
  end
end
