redis = require("../utils/redis").client
InvalidArgumentError = require("../errors/InvalidArgumentError")
NotAuthorizedError = require("../errors/NotAuthorizedError")

auth = module.exports = (req, res, next) ->
   return checkForToken(req, res, next)
   redis.get token, (err, result) ->
      return next(err) if err
      return next(new NotAuthorizedError("Invalid access_token")) if not result

      req.user = JSON.parse(result)
      next()

auth.sub = (req, res, next) ->
   return checkForToken(req, res, next)
   redis.get token, (err, result) ->
      return next(err) if err
      return next(new NotAuthorizedError("Invalid access_token")) if not result

      user = JSON.parse(result)

      if user.role in [ "sub", "starter", "allstar", "mvp", "hof" ]
         req.user = user
         next()
      else
         next(new NotAuthorizedError("Do not have required authorization level. Must be 'sub' or higher"))

auth.starter = (req, res, next) ->
   return checkForToken(req, res, next)
   redis.get token, (err, result) ->
      return next(err) if err
      return next(new NotAuthorizedError("Invalid access_token")) if not result

      user = JSON.parse(result)

      if user.role in [ "starter", "allstar", "mvp", "hof" ]
         req.user = user
         next()
      else
         next(new NotAuthorizedError("Do not have required authorization level. Must be 'starter' or higher"))

auth.allstar = (req, res, next) ->
   return checkForToken(req, res, next)
   redis.get token, (err, result) ->
      return next(err) if err
      return next(new NotAuthorizedError("Invalid access_token")) if not result

      user = JSON.parse(result)

      if user.role in [ "allstar", "mvp", "hof" ]
         req.user = user
         next()
      else
         next(new NotAuthorizedError("Do not have required authorization level. Must be 'allstar' or higher."))

auth.mvp = (req, res, next) ->
   return checkForToken(req, res, next)
   redis.get token, (err, result) ->
      return next(err) if err
      return next(new NotAuthorizedError("Invalid access_token")) if not result

      user = JSON.parse(result)

      if user.role in [ "mvp", "hof" ]
         req.user = user
         next()
      else
         next(new NotAuthorizedError("Do not have required authorization level. Must be 'mvp' or higher."))

auth.hof = (req, res, next) ->
   return checkForToken(req, res, next)
   redis.get token, (err, result) ->
      return next(err) if err
      return next(new NotAuthorizedError("Invalid access_token")) if not result

      user = JSON.parse(result)

      if user.role == "hof"
         req.user = user
         next()
      else
         next(new NotAuthorizedError("Do not have required authorization level. Must be 'hof'."))


checkForToken = (req, res, next) ->
   if not token = req.query?.access_token then next(new InvalidArgumentError("Required: access_token"))
