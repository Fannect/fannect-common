misc = require "../utils/misc"
SportsEventML = require "./sub/SportsEventML"

class ScheduleML

   constructor: (doc) ->
      @sportsEvents = []

      schedules = []
      schedules = misc.reachIn(doc, "xts:sports-content-set.sports-content.0.schedule")
      
      # console.log 'schedules', schedules
      # console.log 'doc', misc.reachIn(doc, "xts:sports-content-set.sports-content")
      # sportsContent = misc.reachIn(doc, "xts:sports-content-set.sports-content.0.schedule")
      # for sportsContent in sportsContents
      #    for schedule in sportsContent.schedule 
      #       schedules.push(schedule)

      unless schedules?
         schedules = misc.reachIn(doc, "sports-content.schedule")
         
      unless schedules
         sportsContents = misc.reachIn(doc, "xts:sports-content-set.sports-content")
         for sportsContent in sportsContents
            if sportsContent.schedule?
               schedules = sportsContent.schedule
               break
         
      for s in schedules
         for o in s["sports-event"]
            event = new SportsEventML(o)
            @sportsEvents.push(event) if event.isValid()

module.exports = ScheduleML