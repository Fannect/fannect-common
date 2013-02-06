TeamProfile = require "../models/TeamProfile"
Team = require "../models/Team"
MongoError = require "../errors/MongoError"
InvalidArgumentError = require "../errors/InvalidArgumentError"
RestError = require "../errors/RestError"

gameDay = module.exports = 

   sameDay: (d1, d2) ->
      return d1.getDate() == d2.getDate() and d1.getMonth() == d2.getMonth() and d1.getFullYear() == d2.getFullYear()

   #
   # options
   #  gameType = type of the game
   #  meta = default properties of the game
   get: (profileId, options, done) ->
      throw new Error("options.gametype is required") unless options.gameType

      TeamProfile
      .findById(profileId)
      .select("team_id waiting_events")
      .exec (err, profile) ->
         return done(new MongoError(err)) if err
         return done(new InvalidArgumentError("Invalid: team_profile_id")) unless profile
      
         Team
         .findById(profile.team_id)
         .select("full_name stadium schedule.pregame")
         .exec (err, team) ->
            return done(new MongoError(err)) if err

            game = team.schedule?.pregame

            if not game?.game_time
               return done null, 
                  available: false
                  home_team:
                     name: team.full_name
                  stadium:
                     name: team.stadium?.name
                     location: team.stadium?.location
                     lat: team.stadium?.coords[1]
                     lng: team.stadium?.coords[0]

            gameInfo =
               game_time: game.game_time
               available: false
               is_home: game.is_home
               home_team:
                  name: if game.is_home then team.full_name else game.opponent
               away_team:
                  name: if game.is_home then game.opponent else team.full_name
               stadium:
                  name: team.schedule.pregame.stadium_name
                  location: team.schedule.pregame.stadium_location
                  lat: team.schedule.pregame.stadium_coords[1]
                  lng: team.schedule.pregame.stadium_coords[0]
               preview: team.schedule.pregame.preview
               in_progress: false
            
            now = new Date()
            gameTime = team.schedule.pregame.game_time

            if now > team.schedule.pregame.game_time
               # game is being played
               gameInfo.in_progress = true
               done null, gameInfo
            else if gameDay.sameDay(now, gameTime)
               # game is today but not yet happening
               gameInfo.available = true

               for ev in profile.waiting_events
                  if ev.type == options.gameType
                     gameInfo.meta = ev.meta
                     return done null, gameInfo
               
               gameInfo.meta = options.meta
               done null, gameInfo
            else
               # no game today
               done null, gameInfo
            
   post: (profileId, options, done) ->
      throw new Error("options.gametype is required") unless options.gameType

      TeamProfile
      .findById(profileId)
      .select("user_id team_id waiting_events")
      .exec (err, profile) ->
         return done(new MongoError(err)) if err
         return done(new InvalidArgumentError("Invalid: team_profile_id")) unless profile
       
         Team
         .findById(profile.team_id)
         .select("full_name schedule.pregame")
         .exec (err, team) ->
            return done(new MongoError(err)) if err

            now = new Date()
            gameTime = team.schedule.pregame.game_time

            if now < gameTime and gameDay.sameDay(now, gameTime)
               # game is today but not yet happening
               for ev in profile.waiting_events
                  if ev.type == options.gameType
                     return done(new RestError("duplicate", "#{options.gameType} already set"))
                     
               profile.waiting_events.push
                  date: now
                  type: options.gameType
                  meta: options.meta

               profile.save (err) ->
                  return done(new MongoError(err)) if err      
                  done null, status: "success"
            else
               done(new RestError("invalid_time", "Cannot set #{options.gameType} after game has happened or not on a game day"))




