RestError = require "./RestError"

class DuplicateError extends RestError
   constructor: (message) ->
      super(400, "duplicate", message)

module.exports = DuplicateError