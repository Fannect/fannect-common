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

   pullProfile: (access_token, twitter, cb) ->
      return cb(new Error("Invalid twitter profile")) unless twitter.user_id

      oa = new OAuth("https://api.twitter.com/oauth/request_token",
         "https://api.twitter.com/oauth/access_token",
         "gFPvxERVpBhfzZh5MNZhQ",
         "xAw41NrcuHoFmdtl45t8tDMgANppe94QnGO0Np3Gak",
         "1.0",
         "#{twitter_redirect}/twitter/callback/#{access_token}",
         "HMAC-SHA1")

      oa.get "http://api.twitter.com/1.1/users/show.json?user_id=#{twitter.user_id}"
      , twitter.access_token
      , twitter.access_token_secret
      , (err, data, resp) ->
         return cb(err) if err
         twitter_user = JSON.parse(data)
         cb(null, twitter_user.profile_image_url.replace("_normal", ""))

   tweet: (access_token, twitter, tweet, cb) ->
      return cb(new Error("Invalid twitter profile")) unless twitter.user_id

      oa = new OAuth("https://api.twitter.com/oauth/request_token",
         "https://api.twitter.com/oauth/access_token",
         "gFPvxERVpBhfzZh5MNZhQ",
         "xAw41NrcuHoFmdtl45t8tDMgANppe94QnGO0Np3Gak",
         "1.0",
         "#{twitter_redirect}/twitter/callback/#{access_token}",
         "HMAC-SHA1")

      hashtag = " #fannect"

      if tweet.length + hashtag.length <= 140
         tweet += hashtag

      oa.post "http://api.twitter.com/1.1/statuses/update.json?user_id=#{twitter.user_id}"
      , twitter.access_token
      , twitter.access_token_secret
      , "status=#{escape(tweet)}"
      , "application/x-www-form-urlencoded"
      , (err, data, resp) ->
         return cb(err) if err
         cb(null)

         