class CreateRides < ActiveRecord::Migration[5.2]
  def change
    create_table :rides do |t|
      t.integer :rider_id
      t.integer :driver_id
      t.time :post_time
      t.string :destination
      t.time :scheduled_time
      t.integer :canceld_by
      t.boolean :finished
      t.integer :rider_review_level
      t.string :rider_review
      t.integer :driver_review_level
      t.integer :driver_review
      t.boolean :review_handled

      t.timestamps
    end
    add_foreign_key :rides, :users, column: :rider_id, primary_key: :id
    add_foreign_key :rides, :users, column: :driver_id, primary_key: :id
  end
end
