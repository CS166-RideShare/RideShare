class CreateRides < ActiveRecord::Migration[5.2]
  def change
    create_table :rides do |t|
      t.integer :rider_id
      t.integer :driver_id
      t.time :post_time
      t.string :destination
      t.time :scheduled_time
      t.integer :canceled_by
      t.boolean :finished
      t.integer :rider_review_level
      t.string :rider_review
      t.integer :driver_review_level
      t.integer :driver_review
      t.boolean :review_handled

      t.timestamps
    end
  end
end
