class RideFinishNotificationChannel < ApplicationCable::Channel
  def subscribed
    stop_all_streams
    stream_from "finish_notice/#{current_user.id}"
  end

  def unsubscribed
    stop_all_streams
  end
end
