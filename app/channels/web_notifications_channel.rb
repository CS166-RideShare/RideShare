class WebNotificationsChannel < ApplicationCable::Channel
  def subscribed(data)
    stop_all_streams
    stream_from "request_channel/#{data['request_id']}"
  end

  def unsubscribed
    stop_all_streams
  end

  def what_is_this
    "what is this???"
  end
end
