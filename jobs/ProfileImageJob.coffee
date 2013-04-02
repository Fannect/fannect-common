async = require "async"
Job = require "./Job"
Huddle = require "../models/Huddle"
Highlight = require "../models/Highlight"

class ProfileImageJob extends Job
   constructor: (data = {}) ->
      data.is_locking = false
      data.type = "profile_image"
      
      if data.user_id and data.new_image_url
         data.meta = 
            user_id: data.user_id
            new_image_url: data.new_image_url
         delete data.user_id
         delete data.new_image_url
      else if not data.meta
         throw new Error("user_id and new_image_url are required to create ProfileImageJob")

      super data

   run: (cb) =>
      async.parallel
         replies: (done) =>
            Huddle.find { "replies.owner_user_id": @meta.user_id }, "replies", (err, huddles) =>
               return done(err) if err or not (huddles?.length > 0)
               q = async.queue (huddle, callback) =>
                  for reply in huddle.replies
                     if @meta.user_id == reply.owner_user_id.toString()
                        reply.owner_profile_image_url = @meta.new_image_url
                  huddle.save(callback)
               , 10
               q.push(huddle) for huddle in huddles
               q.drain = done
         highlights: (done) =>
            Highlight.update { owner_user_id: @meta.user_id }
            , { owner_profile_image_url: @meta.new_image_url }
            , done
         comments: (done) =>
            Highlight.find { "comments.owner_user_id": @meta.user_id }, "comments", (err, highlights) =>
               return done(err) if err or not (highlights?.length > 0)
               q = async.queue (highlight, callback) =>
                  for comment in highlight.comments
                     if @meta.user_id == comment.owner_user_id.toString()
                        comment.owner_profile_image_url = @meta.new_image_url
                  highlight.save(callback)
               , 10
               q.push(highlight) for highlight in highlights
               q.drain = done
      , cb

module.exports = ProfileImageJob
