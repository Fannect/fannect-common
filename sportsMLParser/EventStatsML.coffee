misc = require "../utils/misc"
SportsEventML = require "./sub/SportsEventML"

class EventStatsML

   constructor: (doc) ->
      @sportsEvents = []

      for o in misc.reachIn(doc, "xts:sports-content-set.sports-content.0.sports-event")
         event = new SportsEventML(o)
         @sportsEvents.push(event) if event.isValid()


module.exports = EventStatsML