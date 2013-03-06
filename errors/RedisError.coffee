RestError = require "./RestError"

class RedisError extends RestError
   constructor: (error) ->
      super(400, error.reason, error.message)

module.exports = RedisError