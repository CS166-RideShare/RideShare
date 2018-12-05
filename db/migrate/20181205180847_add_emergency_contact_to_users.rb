class AddEmergencyContactToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :emergency_contact, :string
  end
end
