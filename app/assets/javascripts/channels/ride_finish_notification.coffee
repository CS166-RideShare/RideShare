App.ride_finish_notification = App.cable.subscriptions.create "RideFinishNotificationChannel",
  connected: ->
    # Called when the subscription is ready for use on the server
    if rideId = $("[data-channel*='finish_notifications']").data('ride-id')
      @perform 'subscribed', ride_id: rideId
    else
      @perform 'unsubscribed'

  disconnected: ->
    # Called when the subscription has been terminated by the server

  received: (data) ->
    # Called when there's incoming data on the websocket for this channel
    $("#ride-request-window").find(".modal-content").html(data['accepted'])
    $("#ride-request-window").modal('show');
