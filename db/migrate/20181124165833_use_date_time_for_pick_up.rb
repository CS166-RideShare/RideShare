class UseDateTimeForPickUp < ActiveRecord::Migration[5.2]
  def change
    change_table :rides do |t|
      t.change :pickup_start, :datetime
      t.change :pickup_end, :datetime
    end
  end
end
