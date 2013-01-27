redis = require("../utils/redis").client
InvalidArgumentError = require("../errors/InvalidArgumentError")
NotAuthorizedError = require("../errors/NotAuthorizedError")

module.exports =
   rookieStatus: (req, res, next) ->
      return unless token = hasToken(req, res, next)
      redis.get token, (err, result) ->
         return next(err) if err
         return next(new NotAuthorizedError("Invalid access_token")) if not result
         req.user = JSON.parse(result)
         next()

   subStatus: (req, res, next) ->
      return unless token = hasToken(req, res, next)
      redis.get token, (err, result) ->
         return next(err) if err
         return next(new NotAuthorizedError("Invalid access_token")) if not result

         user = JSON.parse(result)

         if user.role in [ "sub", "starter", "allstar", "mvp", "hof" ]
            req.user = user
            next()
         else
            next(new NotAuthorizedError("Do not have required authorization level. Must be 'sub' or higher"))

   starterStatus: (req, res, next) ->
      return unless token = hasToken(req, res, next)
      redis.get token, (err, result) ->
         return next(err) if err
         return next(new NotAuthorizedError("Invalid access_token")) if not result

         user = JSON.parse(result)

         if user.role in [ "starter", "allstar", "mvp", "hof" ]
            req.user = user
            next()
         else
            next(new NotAuthorizedError("Do not have required authorization level. Must be 'starter' or higher"))

   allstarStatus: (req, res, next) ->
      return unless token = hasToken(req, res, next)
      redis.get token, (err, result) ->
         return next(err) if err
         return next(new NotAuthorizedError("Invalid access_token")) if not result

         user = JSON.parse(result)

         if user.role in [ "allstar", "mvp", "hof" ]
            req.user = user
            next()
         else
            next(new NotAuthorizedError("Do not have required authorization level. Must be 'allstar' or higher."))

   mvpStatus: (req, res, next) ->
      return unless token = hasToken(req, res, next)
      redis.get token, (err, result) ->
         return next(err) if err
         return next(new NotAuthorizedError("Invalid access_token")) if not result

         user = JSON.parse(result)

         if user.role in [ "mvp", "hof" ]
            req.user = user
            next()
         else
            next(new NotAuthorizedError("Do not have required authorization level. Must be 'mvp' or higher."))

   hofStatus: (req, res, next) ->
      return unless token = hasToken(req, res, next)
      redis.get token, (err, result) ->
         return next(err) if err
         return next(new NotAuthorizedError("Invalid access_token")) if not result

         user = JSON.parse(result)

         if user.role == "hof"
            req.user = user
            next()
         else
            next(new NotAuthorizedError("Do not have required authorization level. Must be 'hof'."))

hasToken = (req, res, next) ->
   if not token = req.query?.access_token
      next(new InvalidArgumentError("Required: access_token"))
   else
      return token
