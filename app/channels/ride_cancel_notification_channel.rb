class RideCancelNotificationChannel < ApplicationCable::Channel
  def subscribed(data)
    stop_all_streams
    if data['role']=='driver'
      stream_from "cancel_notice/#{data['ride_id']}/driver"
    elsif data['role']=='rider'
      stream_from "cancel_notice/#{data['ride_id']}/rider"
    end
  end

  def unsubscribed
    stop_all_streams
  end
end
