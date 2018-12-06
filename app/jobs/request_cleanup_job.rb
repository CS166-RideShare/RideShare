class RequestCleanupJob < ApplicationJob
  queue_as :default
  after_perform do |job|
    # invoke another job at your time of choice
    self.class.set(wait: 15.minutes).perform_later()
  end

  def perform(*args)
    Ride.available.where("pickup_end >= ?", DateTime.now).destroy_all
  end
end
