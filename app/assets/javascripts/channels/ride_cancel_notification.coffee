App.ride_cancel_notification = App.cable.subscriptions.create "RideCancelNotificationChannel",
  connected: ->
    # Called when the subscription is ready for use on the server

  disconnected: ->
    # Called when the subscription has been terminated by the server

  received: (data) ->
    # Called when there's incoming data on the websocket for this channel
    if $("[data-channel*='cancel_notifications'][data-role='driver']").data("ride-id") == data['ride_id']
      $("#drive-set-window").find(".modal-content").html(data['accepted'])
    if $("[data-channel*='cancel_notifications'][data-role='rider']").data("ride-id") == data['ride_id']
      $("#ride-request-window").find(".modal-content").html(data['accepted'])

    if data['target'] == 'rider'
      $(".request_notice").prop("hidden", false);
      $("#request_notice_items").prop("hidden", false);
      $("#request_index").find("#"+data['ride_id']).remove();
      
    if data['target'] == 'driver'
      $(".driving_notice").prop("hidden", false);
      $("#driving_notice_items").prop("hidden", false);
      $("#driving_index").find("#"+data['ride_id']).remove();
