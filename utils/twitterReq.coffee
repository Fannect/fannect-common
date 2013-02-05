express = require "express"
auth = require "../middleware/authenticate"
OAuth = require("oauth").OAuth
MongoError = require "../errors/MongoError"
RestError = require "../errors/RestError"
RedisError = require "../errors/RedisError"
InvalidArgumentError = require "../errors/InvalidArgumentError"
NotAuthorizedError = require "../errors/NotAuthorizedError"
async = require "async"
User = require "../models/User"

twitter_redirect = process.env.TWITTER_CALLBACK or "http://localhost:2200"

twitter = module.exports = 

   pullProfile: (twitter, cb) ->
      return cb(new Error("Invalid twitter profile")) unless twitter.user_id

      oa = new OAuth("https://api.twitter.com/oauth/request_token",
         "https://api.twitter.com/oauth/access_token",
         "gFPvxERVpBhfzZh5MNZhQ",
         "xAw41NrcuHoFmdtl45t8tDMgANppe94QnGO0Np3Gak",
         "1.0",
         "#{twitter_redirect}/twitter/callback/#{req.query.access_token}",
         "HMAC-SHA1")

      oa.get "http://api.twitter.com/1.1/users/show.json?user_id=#{user.twitter.user_id}"
      , user.twitter.access_token
      , user.twitter.access_token_secret
      , (err, data, resp) ->
         return cb(err) if err

         console.log "DATA", data

         twitter_user = JSON.parse(data)
         cb(null, twitter_user)

   tweet: (twitter, tweet, cb) ->
      return cb(new Error("Invalid twitter profile")) unless twitter.user_id

      oa = new OAuth("https://api.twitter.com/oauth/request_token",
         "https://api.twitter.com/oauth/access_token",
         "gFPvxERVpBhfzZh5MNZhQ",
         "xAw41NrcuHoFmdtl45t8tDMgANppe94QnGO0Np3Gak",
         "1.0",
         "#{twitter_redirect}/twitter/callback/#{req.query.access_token}",
         "HMAC-SHA1")

      hashtag = " #fannect"

      if tweet.length + hashtag.length <= 140
         tweet += hashtag

      oa.post "http://api.twitter.com/1.1/statuses/update.json?user_id=#{user.twitter.user_id}"
      , user.twitter.access_token
      , user.twitter.access_token_secret
      , "status=#{escape(tweet)}"
      , "application/x-www-form-urlencoded"
      , (err, data, resp) ->
         return cb(err) if err

         