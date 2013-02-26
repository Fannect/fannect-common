class RestError
   constructor: (code, reason, message) ->  
      if typeof code == "string"
         reason = code
         code = null
         
      @code = code or 400
      @reason = reason
      @message = message

   toResObject: () =>
      return {
         status: "fail"
         reason: @reason
         message: @message
      }

module.exports = RestError