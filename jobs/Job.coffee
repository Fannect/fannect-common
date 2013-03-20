redis = (require "../utils/redis").queue

class Job
   constructor: (data) ->
      @type = data.type
      @is_locking = data.is_locking or false
      @locking_id = data.locking_id
      @meta = data.meta or {}
      @created_at = data.created_at or new Date()

   run: () -> throw new Error("Run must be overriden!")
   queue: (redis_client, cb) =>
      # shift arguments if only cb is supplied
      if typeof redis_client == "function" and arguments.length == 2
         cb = redis_client
         redis_client = null
            
      # use passed in connection or default
      queue = redis_client or redis

      jobDef = JSON.stringify(@)
      queue.multi()
      .lpush("job_queue", jobDef)
      .publish("new_job", jobDef)
      .exec(cb)

module.exports = Job
module.exports.types = 
   rename: require "./RenameJob"
   profile_image: require "./ProfileImageJob"

module.exports.create = (json) ->
   if typeof json == "string"
      json = JSON.parse(json)

   if JobType = module.exports.types[json.type]
      return new JobType(json)

   return new Job(json)