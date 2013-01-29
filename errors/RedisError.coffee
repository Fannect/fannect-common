RestError = require "./RestError"

class RedisError extends RestError
   constructor: (reason, message) ->
      super(400, reason, message)

module.exports = RedisError