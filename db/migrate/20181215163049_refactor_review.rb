class RefactorReview < ActiveRecord::Migration[5.2]
  def change
    change_table :reviews do |t|
      t.change_default :review_handled, false
      t.remove :rider_review
      t.remove :rider_review_level
      t.remove :driver_review
      t.remove :driver_review_level
      t.integer :target
      t.integer :review_level
      t.text :review
    end
  end
end
