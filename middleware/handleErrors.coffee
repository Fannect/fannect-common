RestError = require "../errors/RestError"

module.exports = (err, req, res, next) ->
   if err
      console.log err
      console.log err.stack if err.stack
      if RestError.prototype.isPrototypeOf(err)
         return res.json err.code, err.toResObject()
      else
         # console.error err.stack
         return res.json
            status: "fail"
            message: err
   else 
      next()