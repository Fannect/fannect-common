async = require "async"
Job = require "./Job"
Huddle = require "../models/Huddle"

class RenameJob extends Job
   constructor: (data = {}) ->
      data.is_locking = false
      data.type = "rename"
      
      if data.user_id and data.new_name
         data.meta = 
            user_id: data.user_id
            new_name: data.new_name
         delete data.user_id
         delete data.new_name
      else if not data.meta
         throw new Error("user_id and new_name are required to create RenameJob")

      super data

   run: (cb) =>
      async.parallel
         replies: (done) =>
            Huddle.find { "replies.owner_user_id": @meta.user_id }, "replies", (err, huddles) =>
               return cb(err) if err or not (huddles?.length > 0)
               q = async.queue (huddle, callback) =>
                  for reply in huddle.replies
                     if @meta.user_id == reply.owner_user_id.toString()
                        reply.owner_name = @meta.new_name
                  huddle.save(callback)
               , 10

               q.push(huddle) for huddle in huddles
               q.drain = done
         huddles: (done) =>
            Huddle.update { owner_user_id: @meta.user_id }
            , { owner_name: @meta.new_name }
            , done
      , cb

module.exports = RenameJob
