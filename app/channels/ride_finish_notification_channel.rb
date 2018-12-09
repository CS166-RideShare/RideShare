class RideFinishNotificationChannel < ApplicationCable::Channel
  def subscribed(data)
    stop_all_streams
    stream_from "finish_notice/#{data['ride_id']}"
  end

  def unsubscribed
    stop_all_streams
  end
end
