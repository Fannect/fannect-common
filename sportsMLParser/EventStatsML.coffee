misc = require "../utils/misc"
SportsEventML = require "./sub/SportsEventML"

class EventStatsML

   constructor: (doc) ->
      @sportsEvents = []

      for c in misc.reachIn(doc, "xts:sports-content-set.sports-content")
         for o in c["sports-event"]
            event = new SportsEventML(o)
            @sportsEvents.push(event) if event.isValid()


module.exports = EventStatsML