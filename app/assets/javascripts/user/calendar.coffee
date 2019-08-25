$(document).on 'turbolinks:load', ->
  date_current = $('#data').data('date_current');
  events = $('#data').data('events');
  $('#calendar').fullCalendar {
    defaultDate: date_current["value"],
    defaultView: 'agendaWeek',
    events: events,
  }
  return

$(document).on 'turbolinks:before-cache', ->
  $('#calendar').empty()
  return

  