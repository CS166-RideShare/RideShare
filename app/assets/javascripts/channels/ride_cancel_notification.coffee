App.ride_cancel_notification = App.cable.subscriptions.create "RideCancelNotificationChannel",
  connected: ->
    # Called when the subscription is ready for use on the server

  disconnected: ->
    # Called when the subscription has been terminated by the server

  notice: (content, id) ->
    @perform 'destroy_notice', notice_id: id
    new PNotify({
      title: 'Sorry!',
      text: content,
      type: 'error'
    });

  received: (data) ->
    #w hen someone cancel ride
    # Called when there's incoming data on the websocket for this channel
    if $("[data-channel*='cancel_notifications'][data-role='driver']").data("ride-id") == data['ride_id']
      $("#drive-set-window").find(".modal-content").html(data['accepted'])
      $("#details-window").find(".modal-content").html(data['accepted'])
      
    if $("[data-channel*='cancel_notifications'][data-role='rider']").data("ride-id") == data['ride_id']
      $("#ride-request-window").find(".modal-content").html(data['accepted'])
      $("#details-window").find(".modal-content").html(data['accepted'])

    if data['target'] == 'rider'
      $(".request_notice").prop("hidden", false);
      $("#request_notice_items").prop("hidden", false);
      $("#request_notice_items").find(".canceled").html(data['notice']);
      $("#request_index").find("#"+data['ride_id']).remove();
      @notice(data['notice_content'], data['notice_id']);

    if data['target'] == 'driver'
      $(".driving_notice").prop("hidden", false);
      $("#driving_notice_items").prop("hidden", false);
      $("#driving_notice_items").find(".canceled").html(data['notice']);
      $("#driving_index").find("#"+data['ride_id']).remove();
      @notice(data['notice_content'], data['notice_id']);
