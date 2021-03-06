class RideCancelNotificationChannel < ApplicationCable::Channel
  include ChannelNoticeHelper

  def subscribed
    stop_all_streams
    stream_from "cancel_notice/#{current_user.id}"
  end

  def unsubscribed
    stop_all_streams
  end
end
