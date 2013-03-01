_ = require "underscore"
RestError = require "../errors/RestError"
MongoError = require "../errors/MongoError"

meta = module.exports = 

   get: 
      raw: (info, status, next) ->
         status.meta = info.meta

         for ev in info.profile.waiting_events
            if ev.type == info.gameType and ev.event_key == status.event_key
               _.extend(status.meta, ev.meta)
               break

         next()

   set: 
      raw: (info, status, next) ->
         return next(new RestError("invalid_time")) unless status.available
         for ev in info.profile.waiting_events
            if ev.type == info.gameType and ev.event_key == status.event_key
               return next(new RestError("duplicate", "#{info.gameType} already set"))
               
         info.profile.waiting_events.push
            event_key: status.event_key
            type: info.gameType
            meta: info.meta

         info.profile.save (err) ->
            return next(new MongoError(err)) if err      
            next()

      extend: (info, status, next) ->
         return next(new RestError("invalid_time")) unless status.available
         
         ev = null
         for event in info.profile.waiting_events
            if event.type == info.gameType and event.event_key == status.event_key 
               ev = event
               break

         if ev
            _.extend(ev.meta, info.meta)
            ev.markModified("meta")
         else
            info.profile.waiting_events.push
               event_key: status.event_key
               type: info.gameType
               meta: info.meta

         info.profile.save (err) ->
            return next(new MongoError(err)) if err      
            next()
