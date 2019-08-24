$(document).on 'turbolinks:load', ->
  date_current = $('#data').data('date_current');
  staff_shifts = $('#data').data('staff_shifts');
  $('#calendar').fullCalendar {
    defaultDate: date_current["value"],
    defaultView: 'agendaWeek',
    events: staff_shifts
  }
  return

$(document).on 'turbolinks:before-cache', ->
  $('#calendar').empty()
  return

  