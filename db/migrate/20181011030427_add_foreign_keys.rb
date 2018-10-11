class AddForeignKeys < ActiveRecord::Migration[5.2]
  def change
    add_foreign_key :rides, :users, column: :rider_id, primary_key: :id
    add_foreign_key :rides, :users, column: :driver_id, primary_key: :id
  end
end
