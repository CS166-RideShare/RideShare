class RideFinishNotificationChannel < ApplicationCable::Channel
  def subscribed
    stop_all_streams
    stream_from "finish_notice"
  end

  def unsubscribed
    stop_all_streams
  end
end
