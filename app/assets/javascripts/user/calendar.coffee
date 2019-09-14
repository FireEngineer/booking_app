$(document).on 'turbolinks:load', ->
  default_date = $('#data').data('date_current');
  events = $('#data').data('events');
  data_calendar = $('#data').data('data_calendar');
  unless data_calendar
    return
  $('#calendar').fullCalendar {
    height: window.innerHeight - 100,
    selectLongPressDelay: 500,
    validRange: {
      start: data_calendar["start_date"],
      end: data_calendar["end_date"]
    },
    allDaySlot: false,
    navLinks: true,
    defaultDate: default_date,
    editable: true,
    eventDurationEditable: false,
    selectable: true,
    eventClick: (eventObj)->
      if eventObj.classNames[0] == "staff_rest"
        console.log("staff_rest");
        $.get("staff_rest_times/#{eventObj.classNames[1]}/edit");
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
    events: events,
    select: (startStr, endStr) ->
      $.get("user_tasks/new?start_time=#{startStr.format()}&end_time=#{endStr.format()}");
      return
    eventDrop: (event, delta, revertFunc) ->
      if event.classNames[0] == "staff_rest"
        if !confirm('休憩時間を変更しますか？')
          revertFunc()
          return
        else
          $.get("staff_rest_times/#{event.classNames[1]}/update_by_drop?rest_start_time=#{event.start.format()}&rest_end_time=#{event.end.format()}").always((data, textStatus, jqXHR) ->
              if data["responseText"] == "success"
              # 成功の場合の処理
                console.log("成功");
                console.log(data);
                return
              else
                alert(data["responseText"])
                console.log(data["responseText"]);
                console.log(data);
                revertFunc()
                return
            )
          return
      else
        if !confirm('予約時間を変更しますか？')
          revertFunc()
          return
        else
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
          return
  }
  return

$(document).on 'turbolinks:before-cache', ->
  $('#calendar').empty()
  return