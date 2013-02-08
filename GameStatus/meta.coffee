RestError = require "../errors/RestError"
MongoError = require "../errors/MongoError"

meta = module.exports = 

   get: 
      raw: (info, status, next) ->
         for ev in info.profile.waiting_events
            if ev.type == info.gameType
               status.meta = ev.meta
               return next()

         status.meta = info.meta
         next()

   set: 
      raw: (info, status, next) ->
         return next(new RestError("invalid_time")) unless status.available
         for ev in info.profile.waiting_events
            if ev.type == info.gameType
               return next(new RestError("duplicate", "#{info.gameType} already set"))
               
         info.profile.waiting_events.push
            date: new Date()
            type: info.gameType
            meta: info.meta

         info.profile.save (err) ->
            return next(new MongoError(err)) if err      
            next()
      