RestError = require "./RestError"

class InvalidArgumentError extends RestError
   constructor: (reason, message) ->
      super(400, reason, message)

module.exports = InvalidArgumentError