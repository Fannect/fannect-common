RestError = require "./RestError"

class ResourceNotFoundError extends RestError
   constructor: (message) ->
      message = message or "Resource not found"
      super(404, "not_found", message)

module.exports = ResourceNotFoundError