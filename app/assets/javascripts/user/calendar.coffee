$(document).on 'turbolinks:load', ->
  date_current = $('#data').data('date_current');
  events = $('#data').data('events');
  $('#calendar').fullCalendar {
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
    defaultDate: date_current["value"],
    defaultView: 'agendaWeek',
    header: {
      left: 'prev,next today',
      center: 'title',
      right: 'agendaDay,agendaWeek,listDay,listWeek,listMonth'
    },
    businessHours: {
      dow: [ 1, 2, 3, 4 ],
      start: '10:00',
      end: '18:00',
    },
    events: events,
    select: (startStr, endStr) ->
      $.get("user_tasks/new?start_time=#{startStr.format()}&end_time=#{endStr.format()}");
      return
  }
  return

$(document).on 'turbolinks:before-cache', ->
  $('#calendar').empty()
  return

  