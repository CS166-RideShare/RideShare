class CreateNotices < ActiveRecord::Migration[5.2]
  def change
    create_table :notices do |t|
      t.integer :ride_id
      t.integer :user_id
      t.string :target
      t.string :kind
      t.text :content
      t.timestamps
    end
  end
end
