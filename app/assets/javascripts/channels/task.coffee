$(document).on 'turbolinks:load', ->
  user_id = $('#task_notice_user').data('user_id');
  App.task = App.cable.subscriptions.create { channel: 'TaskChannel', user_id: user_id },
    connected: ->
      # Called when the subscription is ready for use on the server

    disconnected: ->
      # Called when the subscription has been terminated by the server

    received: (data) ->
      console.log(data);
      $.notify("予約が入りました", "success");

    speak: (data) ->
      @perform 'speak', user_id: $('#task_notice_user').data('user_id');
