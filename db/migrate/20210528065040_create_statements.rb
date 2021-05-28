class CreateStatements < ActiveRecord::Migration[6.1]
  def change
    create_table :statements do |t|
      t.string :statement_type
      t.string :action
      t.integer :user_id
      t.integer :post_id
      t.integer :admin_id
      t.string :debit_from
      t.string :credit_to
      t.float :amount
      t.float :debitor_balance

      t.timestamps
    end
  end
end
