App.web_notifications = App.cable.subscriptions.create "WebNotificationsChannel",
  connected: ->
    # Called when the subscription is ready for use on the server

  disconnected: ->
    # Called when the subscription has been terminated by the server

  notice: (content, id) ->
    new PNotify({
      title: 'Accepted!',
      text: content,
      type: 'success'
    });
    @perform 'destroy_notice', notice_id: id

  received: (data) ->
    #rider request accepted
    # Called when there's incoming data on the websocket for this channel
    if $("[data-channel*='web_notifications']").data("request-id") == data['request_id']
      $("#ride-request-window").find(".modal-content").html(data['accepted']);
      $("#details-window").find(".modal-content").html(data['accepted']);

    $(".request_notice").prop("hidden", false);
    $("#request_notice_items").prop("hidden", false);
    $("#request_notice_items").find(".accepted").html(data['notice']);
    $("#request_index").find("#"+data['request_id']).find("[name='details']").val('ride');
    $("#request_index").find("#"+data['request_id']).find(".request_status").html('accepted');
    $(@notice(data['notice_content'], data['notice_id']));
