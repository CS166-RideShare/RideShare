App.web_notifications = App.cable.subscriptions.create "WebNotificationsChannel",
  connected: ->
    # Called when the subscription is ready for use on the server
    requestId = $("[data-channel='web_notifications']").data('request-id')
    if requestId
      @perform 'subscribed', request_id: requestId
    else
      @perform 'unsubscribed'

  disconnected: ->
    # Called when the subscription has been terminated by the server

  received: (data) ->
    # Called when there's incoming data on the websocket for this channel
    $("#ride-request-window").find(".modal-content").html(data['accepted'])
    $("#ride-request-window").modal('show');
    App.ride_cancel_notification.connected();
    App.ride_finish_notification.connected();
