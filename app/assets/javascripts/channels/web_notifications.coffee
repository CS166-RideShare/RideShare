App.web_notifications = App.cable.subscriptions.create "WebNotificationsChannel",
  connected: ->
    # Called when the subscription is ready for use on the server

  disconnected: ->
    # Called when the subscription has been terminated by the server

  received: (data) ->
    #rider request accepted
    # Called when there's incoming data on the websocket for this channel
    if $("[data-channel*='web_notifications']").data("request-id") == data['request_id']
      $("#ride-request-window").find(".modal-content").html(data['accepted']);
      $("#details-window").find(".modal-content").html(data['accepted']);

    $(".request_notice").prop("hidden", false);
    $("#request_notice_items").prop("hidden", false);
    $("#request_index").find("#"+data['request_id']).find("[name='details']").val('ride');
