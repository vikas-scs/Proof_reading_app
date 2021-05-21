class CreateUserWallets < ActiveRecord::Migration[6.1]
  def change
    create_table :user_wallets do |t|
      t.integer :user_id
      t.float :balance
      t.float :lock_balance

      t.timestamps
    end
  end
end
