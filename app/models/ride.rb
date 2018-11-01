class Ride < ApplicationRecord
  belongs_to :rider, class_name: "User", foreign_key: :rider_id
  belongs_to :driver, class_name: "User", foreign_key: :driver_id, optional: true

  scope :available, -> { where(driver_id: nil) }
end
