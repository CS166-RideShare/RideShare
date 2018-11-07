class CreateRides < ActiveRecord::Migration[5.2]
  def change
    create_table :rides do |t|
      t.integer :rider_id
      t.integer :driver_id
      t.string :starting_id
      t.string :destination_id
      t.string :starting_address
      t.string :destination_address
      t.time :pickup_time
      t.integer :canceled_by
      t.boolean :finished

      t.timestamps
    end
  end
end
