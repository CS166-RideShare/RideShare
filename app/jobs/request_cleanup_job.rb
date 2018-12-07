class RequestCleanupJob < ApplicationJob
  queue_as :default

  def perform(rid)
    request = Ride.available.find(rid)
    unless request.nil?
      Ride.transaction do
        request.lock!
        request.destroy!
      end
    end
  end
end
