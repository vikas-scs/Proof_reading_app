class CreateCuponsUsers < ActiveRecord::Migration[6.1]
  def change
    create_table :cupons_users do |t|
      t.integer :user_id
      t.integer :cupon_id

      t.timestamps
    end
  end
end
