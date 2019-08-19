# $(document).on 'turbolinks:load', ->
#   $('#calendar').fullCalendar {
#     plugins: [ 'interaction', 'dayGrid' ],
#     timeZone: 'UTC',
#     defaultView: 'dayGridWeek',
#     header: {
#       left: 'prev,next',
#       center: 'title',
#       right: 'dayGridDay,dayGridWeek'
#     },
#     editable: true,
#     events: 'https://fullcalendar.io/demo-events.json'
#   }
#   return

$(document).on 'turbolinks:load', ->
  $('#calendar').fullCalendar {
    defaultView: 'agendaFourDay',
    groupByResource: true,
    header: {
      left: 'prev,next',
      center: 'title',
      right: 'agendaDay,agendaFourDay'
    },
    views: {
      agendaFourDay: {
        type: 'agenda',
        duration: { days: 4 }
      }
    },
    resources: [
      { id: 'a', title: 'Room A' },
      { id: 'b', title: 'Room B' }
    ],
    events: 'https://fullcalendar.io/demo-events.json?with-resources=2'
  }
  return

$(document).on 'turbolinks:before-cache', ->
  $('#calendar').empty()
  return

  