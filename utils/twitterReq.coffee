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
request = require "request"
# crypt = require "./crypt"

twitter_redirect = process.env.TWITTER_CALLBACK or "http://localhost:2200"

twitter = module.exports = 

   pullProfile: (access_token, twitter, cb) ->
      return cb(new Error("Invalid twitter profile")) unless twitter.user_id

      oauth = 
         consumer_key: "gFPvxERVpBhfzZh5MNZhQ"
         consumer_secret: "xAw41NrcuHoFmdtl45t8tDMgANppe94QnGO0Np3Gak"
         token: twitter.access_token
         token_secret: twitter.access_token_secret

      request.get
         url: "http://api.twitter.com/1.1/users/show.json?user_id=#{twitter.user_id}"
         oauth: oauth
      , (err, resp, body) ->
         return cb(err) if err
         twitter_user = JSON.parse(body)
         cb(null, twitter_user.profile_image_url.replace("_normal", ""))

   tweet: (access_token, twitter, tweet, cb) ->
      return cb(new Error("Invalid twitter profile")) unless twitter.user_id

      oauth = 
         consumer_key: "gFPvxERVpBhfzZh5MNZhQ"
         consumer_secret: "xAw41NrcuHoFmdtl45t8tDMgANppe94QnGO0Np3Gak"
         token: twitter.access_token
         token_secret: twitter.access_token_secret

      hashtag = " #shout"

      if tweet.length + hashtag.length <= 140
         tweet += hashtag

      request.post
         url: "http://api.twitter.com/1.1/statuses/update.json"
         oauth: oauth
         body: "status=#{escape(tweet)}"
      , (err, resp, body) ->
         return cb(err) if err
         cb(null)
