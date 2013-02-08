create = require "./create"
availability = require "./availability"
metaUtils = require "./meta"

class GameStatus 

   constructor: (profileId, gameType, action, cb) ->
      throw new Error("profile id and game type are required!") unless profileId and gameType
      @profileId = profileId
      @gameType = gameType
      @metadata = {}
      @action = action or "get"
      @commands =
         create: create
         availability: availability.before

      @exec(cb) if cb

   availability: (type) =>
      fn = availability[type]
      throw new Error("Invalid availability type") unless fn
      @commands.availability = fn
      return @

   meta: (type, meta) =>
      fn = metaUtils[@action][type]
      throw Error("Invalid meta type") unless fn
      @commands.meta = fn
      @metadata = meta if meta
      return @

   exec: (cb) =>
      info = { profileId: @profileId, gameType: @gameType, meta: @metadata }
      status = {}
      series = [
         @commands.create, 
         @commands.availability,
         @commands.meta
      ]

      execute = () ->
         command = series.shift()
         if command
            command info, status, (err) ->
               return cb(err) if err
               execute()
         else
            # Finished, time to return result
            cb null, status

      execute()

module.exports = GameStatus
module.exports.get = (profileId, gameType, cb) ->
   return new GameStatus(profileId, gameType, "get", cb)

module.exports.set = (profileId, gameType, cb) ->
   return new GameStatus(profileId, gameType, "set", cb)
