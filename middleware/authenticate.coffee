redis = require("../utils/redis").client
InvalidArgumentError = require("../errors/InvalidArgumentError")
NotAuthorizedError = require("../errors/NotAuthorizedError")

module.exports =
   rookie: (req, res, next) ->
      return unless hasToken(req, res, next)
      redis.get token, (err, result) ->
         return next(err) if err
         return next(new NotAuthorizedError("Invalid access_token")) if not result

         req.user = JSON.parse(result)
         next()

   sub: (req, res, next) ->
      return unless hasToken(req, res, next)
      redis.get token, (err, result) ->
         return next(err) if err
         return next(new NotAuthorizedError("Invalid access_token")) if not result

         user = JSON.parse(result)

         if user.role in [ "sub", "starter", "allstar", "mvp", "hof" ]
            req.user = user
            next()
         else
            next(new NotAuthorizedError("Do not have required authorization level. Must be 'sub' or higher"))

   starter: (req, res, next) ->
      return unless hasToken(req, res, next)
      redis.get token, (err, result) ->
         return next(err) if err
         return next(new NotAuthorizedError("Invalid access_token")) if not result

         user = JSON.parse(result)

         if user.role in [ "starter", "allstar", "mvp", "hof" ]
            req.user = user
            next()
         else
            next(new NotAuthorizedError("Do not have required authorization level. Must be 'starter' or higher"))

   allstar: (req, res, next) ->
      return unless hasToken(req, res, next)
      redis.get token, (err, result) ->
         return next(err) if err
         return next(new NotAuthorizedError("Invalid access_token")) if not result

         user = JSON.parse(result)

         if user.role in [ "allstar", "mvp", "hof" ]
            req.user = user
            next()
         else
            next(new NotAuthorizedError("Do not have required authorization level. Must be 'allstar' or higher."))

   mvp: (req, res, next) ->
      return unless hasToken(req, res, next)
      redis.get token, (err, result) ->
         return next(err) if err
         return next(new NotAuthorizedError("Invalid access_token")) if not result

         user = JSON.parse(result)

         if user.role in [ "mvp", "hof" ]
            req.user = user
            next()
         else
            next(new NotAuthorizedError("Do not have required authorization level. Must be 'mvp' or higher."))

   hof: (req, res, next) ->
      return unless hasToken(req, res, next)
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
   if not token = req.query?.access_token then next(new InvalidArgumentError("Required: access_token"))
