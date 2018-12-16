App.ride_finish_notification = App.cable.subscriptions.create "RideFinishNotificationChannel",
  connected: ->
    # Called when the subscription is ready for use on the server

  disconnected: ->
    # Called when the subscription has been terminated by the server

  notice: (content, id) ->
    new PNotify({
      title: 'Finished!',
      text: content,
      type: 'success'
    });
    @perform 'destroy_notice', notice_id: id

  received: (data) ->
    # Called when there's incoming data on the websocket for this channel
    if $("[data-channel*='finish_notifications']").data("ride-id") == data['ride_id']
      $("#ride-request-window").find(".modal-content").html(data['accepted'])
      $("#ride-request-window").modal('show');
      $("#details-window").find(".modal-content").html(data['accepted'])

    $(".request_notice").prop("hidden", false);
    $("#request_notice_items").prop("hidden", false);
    $("#request_notice_items").find(".finished").html(data['notice']);
    $("#request_index").find("#"+data['ride_id']).remove();
    $(@notice(data['notice_content'], data['notice_id']));
