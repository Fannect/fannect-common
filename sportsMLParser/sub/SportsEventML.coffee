misc = require "../../utils/misc"
TeamML = require "./TeamML"

class SportsEventML

   constructor: (eventDoc) ->
      @eventMeta = new EventMetaML(eventDoc["event-metadata"]?[0])
      @teams = []

      for o in eventDoc["team"]
         team = new TeamML(o)
         @teams.push(team) if team.isValid()

   isValid: () => return @eventMeta.isValid()

module.exports = SportsEventML
