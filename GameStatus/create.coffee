TeamProfile = require "../models/TeamProfile"
Team = require "../models/Team"
MongoError = require "../errors/MongoError"
InvalidArgumentError = require "../errors/InvalidArgumentError"

create = module.exports = (info, status, next) ->

   TeamProfile
   .findById(info.profileId)
   .select("team_id waiting_events")
   .exec (err, profile) ->
      return next(new MongoError(err)) if err
      return next(new InvalidArgumentError("Invalid: team_profile_id")) unless profile
      info.profile = profile

      Team
      .findById(profile.team_id)
      .select("full_name stadium schedule.pregame")
      .exec (err, team) ->
         return next(new MongoError(err)) if err
         info.team = team

         game = team.schedule?.pregame

         # Set up status for other middleware
         if not game?.game_time
            status.home_team = team.full_name
            status.stadium = 
               name: team.stadium?.name
               location: team.stadium?.location
               lat: team.stadium?.coords?[1]
               lng: team.stadium?.coords?[0]
         else
            status.game_time = game.game_time
            status.is_home = game.is_home
            status.home_team = 
               name: if game.is_home then team.full_name else game.opponent
            status.away_team =
               name: if game.is_home then game.opponent else team.full_name
            status.stadium =
               name: game.stadium_name
               location: game.stadium_location
               lat: game.stadium_coords?[1]
               lng: game.stadium_coords?[0]

         next()
