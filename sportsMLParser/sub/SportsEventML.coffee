misc = require "../../utils/misc"
TeamML = require "./TeamML"
EventMetaML = require "./EventMetaML"

class SportsEventML

   constructor: (eventDoc) ->
      @eventMeta = new EventMetaML(eventDoc["event-metadata"]?[0])
      @home_team = null
      @away_team = null

      for o in eventDoc["team"]
         team = new TeamML(o)
         if team.isValid()
            if team.isHome() then @home_team = team
            else @away_team = team

   isValid: () => return @eventMeta.isValid()
   isHome: (team_key) => return @home_team.team_key == team_key
   isAway: (team_key) => return @away_team.team_key == team_key
   
module.exports = SportsEventML
