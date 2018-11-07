class CreateReviews < ActiveRecord::Migration[5.2]
  def change
    create_table :reviews do |t|
      t.integer :ride_id
      t.integer :rider_review_level
      t.text :rider_review
      t.integer :driver_review_level
      t.text :driver_review
      t.boolean :review_handled

      t.timestamps
    end
  end
end
