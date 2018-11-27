class Ride < ApplicationRecord
  belongs_to :rider, class_name: "User", foreign_key: :rider_id
  belongs_to :driver, class_name: "User", foreign_key: :driver_id, optional: true
  has_one :review

  scope :available, -> { where(driver_id: nil) }
  scope :unfinished, -> { where.not(driver_id: nil)
                          .where(finished: false, canceled_by: nil) }
end
