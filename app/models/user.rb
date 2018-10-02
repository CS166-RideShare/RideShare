class User < ApplicationRecord

  def rides
    Ride.where(rider_id: @id)
  end

  def drives
    Ride.where(driver_id: @id)
  end
end
