$(document).on 'turbolinks:load', ->
  json_data = $('#holiday_data').data('json_data');
  debugger
  # events = $('#data').data('events');
  $('#holiday_calendar').fullCalendar {
    defaultView: 'month',
    validRange: {
      start: json_data["start_date"],
      end: json_data["end_date"]
    },
    events: json_data["holidays"]
  }
  return

$(document).on 'turbolinks:before-cache', ->
  $('#holiday_calendar').empty()
  return