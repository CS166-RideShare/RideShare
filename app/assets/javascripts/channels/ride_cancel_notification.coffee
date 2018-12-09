App.ride_cancel_notification = App.cable.subscriptions.create "RideCancelNotificationChannel",
  connected: ->
    # Called when the subscription is ready for use on the server
    if rideId = $("[data-channel*='cancel_notifications']").data('ride-id')
      userRole = $("[data-channel*='cancel_notifications']").data('role')
      @perform 'subscribed', ride_id: rideId, role: userRole
    else
      @perform 'unsubscribed'

  disconnected: ->
    # Called when the subscription has been terminated by the server

  received: (data) ->
    # Called when there's incoming data on the websocket for this channel
    userRole = $("[data-channel*='cancel_notifications']").data('role')
    if userRole == 'rider'
      $("#ride-request-window").find(".modal-content").html(data['accepted'])
      $("#ride-request-window").modal('show');
    else if userRole == 'driver'
      $("#drive-set-window").find(".modal-content").html(data['accepted'])
      $("#drive-set-window").modal('show');
