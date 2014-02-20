misc = require "../../utils/misc"

class TeamML

   constructor: (teamDoc) ->
      @team_key = misc.reachIn(teamDoc, "team-metadata.0.$.team-key")
      @alignment = misc.reachIn(teamDoc, "team-metadata.0.$.alignment")

      @score = parseInt(misc.reachIn(teamDoc, "team-stats.0.$.score"))
      @opposing_score = parseInt(misc.reachIn(teamDoc, "team-stats.0.$.score-opposing"))
      @outcome = misc.reachIn(teamDoc, "team-stats.0.$.event-outcome")

   isValid: () => return true # sometimes the team_key can be null for some reason return @team_key
   isHome: () => 
      return true if @alignment == "home"
      return false if @alignment == "away"
      return null 
   won: () =>
      return true if @outcome == "win"
      return false if @outcome == "loss"
      return null

module.exports = TeamML