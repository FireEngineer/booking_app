$(document).on 'turbolinks:load', ->
  date_current = $('#data').data('date_current');
  events = $('#data').data('events');
  $('#calendar').fullCalendar {
    eventClick: (eventObj)->
      if eventObj.url
        alert(
          'Clicked ' + eventObj.title + '.\n' +
          'Will open ' + eventObj.url + ' in a new tab'
        );

        window.open(eventObj.url);

        return false; 
      else 
        alert('Clicked ' + eventObj.title);
      
    ,
    plugins: [ 'timeGrid' ],
    defaultDate: date_current["value"],
    defaultView: 'agendaWeek',
    header: {
      left: 'prev,next today',
      center: 'title',
      right: 'agendaDay,agendaWeek,listDay,listWeek,listMonth'
    },
    events: events,
  }
  return

$(document).on 'turbolinks:before-cache', ->
  $('#calendar').empty()
  return

  