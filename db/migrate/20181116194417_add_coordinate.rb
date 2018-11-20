class AddCoordinate < ActiveRecord::Migration[5.2]
  def change
    change_table :rides do |t|
      t.string :starting_lat
      t.string :starting_lng
      t.string :destination_lat
      t.string :destination_lng
    end
  end
end
