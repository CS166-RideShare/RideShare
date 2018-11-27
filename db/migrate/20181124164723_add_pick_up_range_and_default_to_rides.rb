class AddPickUpRangeAndDefaultToRides < ActiveRecord::Migration[5.2]
  def change
    change_table :rides do |t|
      t.change_default :finished, false
      t.remove :pickup_time
      t.datetime :pickup_start
      t.datetime :pickup_end
    end
  end
end
