class AddWalletToAdmin < ActiveRecord::Migration[6.1]
  def change
    add_column :admins, :wallet, :float
  end
end
