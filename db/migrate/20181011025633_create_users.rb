class CreateUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :users do |t|
      t.string :name
      t.string :email
      t.string :license_number
      t.boolean :is_driver
      t.integer :gender
      t.text :introduction
      t.string :vehicle_make
      t.string :vehicle_model
      t.string :vehicle_plate

      t.timestamps
    end
  end
end
