Job = require "./Job"

class RenameJob extends Job
   constructor: (data = {}) ->
      data.is_locking = false
      data.type = "rename"
      data.meta = 
         user_id: user_id
         new_name: new_name
      
      super data

   run: (cb) =>
      Huddle.find { "replies.owner_user_id": @meta.user_id }, "replies", (err, huddles) ->
         return cb(err) if err or not (huddles?.length > 0)
         q = async.queue (huddle, callback) ->
            for reply in huddle.replies
               if req.user._id == reply.owner_user_id.toString()
                  reply.owner_name = name
            huddle.save(callback)
         , 10

         q.push(huddle) for huddle in huddles
         q.drain = cb

module.exports = RenameJob
