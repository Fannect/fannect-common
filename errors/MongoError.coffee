RestError = require "./RestError"

class MongoError extends RestError
   constructor: (reason, message) ->
      super(400, reason, message)

module.exports = MongoError