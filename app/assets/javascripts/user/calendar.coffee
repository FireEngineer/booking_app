$(document).on 'turbolinks:load', ->
  default_date = $('#data').data('date_current');
  events = $('#data').data('events');
  data_calendar = $('#data').data('data_calendar');
  store_member_id = $('#data').data('store_member_id')
  unless data_calendar
    return
  $('#calendar').fullCalendar {
    height: window.innerHeight - 100,
    selectLongPressDelay: 300,
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
    header: {
      left: 'prev,next today',
      center: 'title',
      right: 'agendaDay,agendaWeek,month'
    },
    events: events,
    select: (startStr, endStr) ->
      if store_member_id
        $.get("user_tasks/new?start_time=#{startStr.format()}&end_time=#{endStr.format()}&store_member_id=#{store_member_id}");
      else
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