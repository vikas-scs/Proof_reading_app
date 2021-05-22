class CreateInvites < ActiveRecord::Migration[6.1]
  def change
    create_table :invites do |t|
      t.integer :post_id
      t.integer :host_id
      t.integer :reciever_id
      t.string :invite_status
      t.string :read_status
      t.integer :error_count

      t.timestamps
    end
  end
end
