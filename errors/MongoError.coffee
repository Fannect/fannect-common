RestError = require "./RestError"

class MongoError extends RestError
   constructor: (err) ->
      if err.code == 11000 or err.code == 11001
         super(409, "duplicate", err)
      else
         super(400, "bad_query", err.message)

module.exports = MongoError