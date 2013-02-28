misc = require "../utils/misc"
SportsEventML = require "./sub/SportsEventML"

class ScheduleML

   constructor: (doc) ->
      @sportsEvents = []

      for o in misc.reachIn(doc, "xts:sports-content-set.sports-content.0.schedule.0.sports-event")
         event = new SportsEventML(o)
         @sportsEvents.push(event) if event.isValid()

module.exports = ScheduleML