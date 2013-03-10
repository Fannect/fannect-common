redis = require("../utils/redis")
mongoose = require("mongoose")
InvalidArgumentError = require("../errors/InvalidArgumentError")
NotAuthorizedError = require("../errors/NotAuthorizedError")
RedisError = require("../errors/RedisError")
crypt = require "../utils/crypt"
App = require "../models/App"

auth = module.exports =
   rookieStatus: (req, res, next) ->
      return unless token = hasToken(req, res, next)
      auth.getUser token, (err, user) ->
         return next(err) if err
         req.user = user
         next()

   subStatus: (req, res, next) ->
      return unless token = hasToken(req, res, next)
      auth.getUser token, (err, user) ->
         return next(err) if err

         if user.role in [ "sub", "starter", "allstar", "mvp", "hof" ]
            req.user = user
            next()
         else
            next(new NotAuthorizedError("Do not have required authorization level. Must be 'sub' or higher"))

   starterStatus: (req, res, next) ->
      return unless token = hasToken(req, res, next)
      auth.getUser token, (err, user) ->
         return next(err) if err

         if user.role in [ "starter", "allstar", "mvp", "hof" ]
            req.user = user
            next()
         else
            next(new NotAuthorizedError("Do not have required authorization level. Must be 'starter' or higher"))

   allstarStatus: (req, res, next) ->
      return unless token = hasToken(req, res, next)
      auth.getUser token, (err, user) ->
         return next(err) if err

         if user.role in [ "allstar", "mvp", "hof" ]
            req.user = user
            next()
         else
            next(new NotAuthorizedError("Do not have required authorization level. Must be 'allstar' or higher."))

   mvpStatus: (req, res, next) ->
      return unless token = hasToken(req, res, next)
      auth.getUser token, (err, user) ->
         return next(err) if err

         if user.role in [ "mvp", "hof" ]
            req.user = user
            next()
         else
            next(new NotAuthorizedError("Do not have required authorization level. Must be 'mvp' or higher."))

   hofStatus: (req, res, next) ->
      return unless token = hasToken(req, res, next)
      auth.getUser token, (err, user) ->
         return next(err) if err

         if user.role == "hof"
            req.user = user
            next()
         else
            next(new NotAuthorizedError("Do not have required authorization level. Must be 'hof'."))

   app: 
      managerStatus: (req, res, next) ->
         return unless token = hasToken(req, res, next)
         auth.getUser token, (err, user) ->
            return next(err) if err

            if user.role in [ "manager", "owner" ]
               req.user = user
               next()
            else
               next(new NotAuthorizedError("Do not have required authorization level. Must be 'manager' or higher."))

      ownerStatus: (req, res, next) ->
         return unless token = hasToken(req, res, next)
         auth.getUser token, (err, app) ->
            return next(err) if err

            if app.role == "owner"
               req.app = app
               next()
            else
               next(new NotAuthorizedError("Do not have required authorization level. Must be 'owner'."))

   createAccessToken: (user, done) ->
      # Create new access_token and store
      access_token = crypt.generateAccessToken()
      auth.setUser(access_token, user, done)

   getUser: (access_token, done) ->
      redis.client.get access_token, (err, result) ->
         return done(new RedisError(err)) if err
         return done(new NotAuthorizedError("Invalid access_token")) if not result
         done(null, JSON.parse(result))

   setUser: (access_token, user, done) ->
      redis.client.setnx access_token, JSON.stringify(user), (err, result) ->
         return done(new RedisError(err)) if err
         
         if result == 0
            # If access_token already exsits then try again
            auth.createAccessToken(user, done)
         else
            # Set expiration
            redis.client.expire access_token, 1800

            done null, access_token

   updateUser: (access_token, user, done) ->
      redis.client.setex access_token, 1800, JSON.stringify(user), (err, result) ->
         return done(new RedisError(err)) if err
         done null, access_token

hasToken = (req, res, next) ->
   if not token = req.query?.access_token
      next(new InvalidArgumentError("Required: access_token"))
   else
      return token
