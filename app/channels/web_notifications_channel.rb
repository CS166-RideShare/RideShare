class WebNotificationsChannel < ApplicationCable::Channel
  include ChannelNoticeHelper
  
  def subscribed
    stop_all_streams
    stream_from "request_channel/#{current_user.id}"
  end

  def unsubscribed
    stop_all_streams
  end
end
