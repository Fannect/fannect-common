create = require "./create"
availability = require "./availability"
metaUtils = require "./meta"
RestError = require "../errors/RestError"

class GameStatus 

   constructor: (profileId, gameType, action, cb) ->
      throw new Error("profile id and game type are required!") unless profileId and gameType
      @profileId = profileId
      @gameType = gameType
      @metadata = {}
      @team = null
      @action = action or "get"
      @commands =
         create: create
         availability: availability.before

      @exec(cb) if cb

   get: (profileId, gameType, cb) =>
      @profileId = profileId if profileId
      @gameType = gameType if gameType
      @action = "get"
      @exec(cb) if cb 
      return @

   set: (profileId, gameType, cb) =>
      @profileId = profileId if profileId
      @gameType = gameType if gameType
      @action = "set"
      @exec(cb) if cb 
      return @

   setProfileId: (profile_id, cb) =>
      @profileId = profile_id
      return @

   setTeam: (team) =>
      @team = team
      return @

   availability: (type) =>
      if typeof type == "function" then fn = type
      else fn = availability[type]
      
      throw new Error("Invalid availability type") unless fn
      @commands.availability = fn
      return @

   meta: (type, meta) =>
      if typeof type == "function"
         fn = (info, status, next) ->
            return next(new RestError("invalid_time")) unless status.available
            type(info, status, next)
      else
         fn = metaUtils[@action][type]
         throw new Error("Invalid meta type") unless fn
      
      @commands.meta = fn
      @metadata = meta if meta
      return @

   afterMeta: (fn) ->
      @commands.afterMeta = fn
      return @

   exec: (cb) =>
      info = { profileId: @profileId, gameType: @gameType, meta: @metadata, team: @team or null }
      status = {}
      series = [
         @commands.create, 
         @commands.availability,
         @commands.meta
      ]

      series.push @commands.afterMeta if @commands.afterMeta

      execute = () =>
         command = series.shift()

         if command
            command info, status, (err) =>
               # Cache team
               @team = info.team if info.team
               return cb(err) if err
               execute()
         else
            # Finished, time to return result
            cb null, status

      execute()

module.exports = GameStatus
module.exports.get = (profileId, gameType, cb) ->
   # shift profileId to gameType 
   gameType = profileId if arguments.length == 1
   return new GameStatus(profileId, gameType, "get", cb)

module.exports.set = (profileId, gameType, cb) ->
   # shift profileId to gameType 
   gameType = profileId if arguments.length == 1
   return new GameStatus(profileId, gameType, "set", cb)
