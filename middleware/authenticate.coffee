redis = require("../utils/redis").client
InvalidArgumentError = require("../errors/InvalidArgumentError")
NotAuthorizedError = require("../errors/NotAuthorizedError")

module.exports = (req, res, next) ->
   console.log InvalidArgumentError
   if not token = req.query?.access_token then next(new InvalidArgumentError("Required: access_token"))

   redis.get token, (err, result) ->
      return next(err) if err
      return next(new NotAuthorizedError("Invalid access_token")) if not result

      req.user = JSON.parse(result)
      next()