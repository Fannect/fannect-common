misc = require "../utils/misc"
SportsEventML = require "./sub/SportsEventML"

class ScheduleML

   constructor: (doc) ->
      @sportsEvents = []

      schedules = []
      sportsContents = misc.reachIn(doc, "xts:sports-content-set.sports-content")
      
      for sportsContent in sportsContents
         for schedule in sportsContent.schedule 
            schedules.push(schedule)

      unless schedules?
         schedules = misc.reachIn(doc, "sports-content.schedule")
         
      for s in schedules
         for o in s["sports-event"]
            event = new SportsEventML(o)
            @sportsEvents.push(event) if event.isValid()

module.exports = ScheduleML