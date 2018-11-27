class AddPickUpRangeAndDefaultToRides < ActiveRecord::Migration[5.2]
  def change
    change_table :rides do |t|
      t.change_default :finished, false
      t.rename :pickup_time, :pickup_start
      t.time :pickup_end
    end
  end
end
