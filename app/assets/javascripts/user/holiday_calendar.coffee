$(document).on 'turbolinks:load', ->
  json_data = $('#holiday_data').data('json_data');
  unless json_data
    return
  $('#holiday_calendar').fullCalendar {
    selectable: true,
    dayClick: (date) ->
      # alert('clicked ' + date.format());
      $.get("iregular_holidays/new/?date=#{date.format()}");
      return
    eventClick: (eventObj) ->
      $.get("iregular_holidays/#{eventObj.id}/edit");
      return
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