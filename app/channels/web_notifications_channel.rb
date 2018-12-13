class WebNotificationsChannel < ApplicationCable::Channel
  def subscribed
    stop_all_streams
    stream_from "request_channel"
  end

  def unsubscribed
    stop_all_streams
  end
end
