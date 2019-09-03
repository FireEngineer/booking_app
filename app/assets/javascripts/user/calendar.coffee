$(document).on 'turbolinks:load', ->
  default_date = $('#data').data('date_current');
  events = $('#data').data('events');
  $('#calendar').fullCalendar {
    navLinks: true,
    defaultDate: default_date,
    editable: true,
    eventDurationEditable: false,
    selectable: true,
    eventClick: (eventObj)->
      if eventObj.url
        alert(
          'Clicked ' + eventObj.title + '.\n' +
          'Will open ' + eventObj.url + ' in a new tab'
        );

        window.open(eventObj.url);

        return false; 
      else 
        $.get("user_tasks/#{eventObj.id}");
    ,
    plugins: [ 'timeGrid' ],
    defaultView: 'agendaWeek',
    views: {
      listDay: { buttonText: 'list(日)' },
      listWeek: { buttonText: 'list(週)' },
      listMonth: { buttonText: 'list(月)' }
    },
    header: {
      left: 'prev,next today',
      center: 'title',
      right: 'agendaDay,agendaWeek,month,listDay,listWeek,listMonth'
    },
    businessHours: {
      dow: [ 1, 2, 3, 4 ],
      start: '10:00',
      end: '20:00',
    },
    events: events,
    select: (startStr, endStr) ->
      $.get("user_tasks/new?start_time=#{startStr.format()}&end_time=#{endStr.format()}");
      return
    eventDrop: (event, delta, revertFunc) ->
      if !confirm('予約時間を変更しますか？')
        revertFunc()
        return
      $.get("user_tasks/#{event.id}/update_by_drop?start_time=#{event.start.format()}&end_time=#{event.end.format()}").always((data, textStatus, jqXHR) ->
          if data["responseText"] == "success"
          # 成功の場合の処理
            console.log("成功");
            console.log(data);
            return
          else
            alert(data)
            console.log(data["responseText"]);
            console.log(data);
            revertFunc()
            return
        )
  }
  return

$(document).on 'turbolinks:before-cache', ->
  $('#calendar').empty()
  return