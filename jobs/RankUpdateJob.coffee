async = require "async"
Job = require "./Job"
TeamProfile = require "../models/TeamProfile"
_ = require "underscore"

class RankUpdateJob extends Job
   constructor: (data = {}) ->
      data.is_locking = true
      data.type = "rank_update"

      if data.team_profile_id and data.team_id
         data.meta =
            team_profile_id: data.team_profile_id
            team_id: data.team_id
         delete data.team_profile_id
         delete data.team_id
      else if not data.meta
         throw new Error("team_profile_id and team_id are required to create RankUpdateJob")
         

      data.locking_id = "rank_#{data.meta.team_id}"
      super data

   run: (cb) =>
      TeamProfile.findById @meta.team_profile_id, "rank points.overall", (err, profile) =>
         return cb(err) if err
         return cb(new Error("Invalid team_profile_id: #{@meta.team_profile_id}")) unless profile

         TeamProfile.find(
            rank: {$lt: profile.rank }
            team_id: @meta.team_id
            "points.overall": { $lt: profile.points.overall }
         ).select("rank")
         .sort("rank")
         .exec (err, profiles) ->
            return cb(err) if err
            return cb() if profiles.length == 0


            # switch profiles to have the highest rank
            profile.rank = profiles[0].rank

            update = []

            # move all other profiles down a rank
            for p in profiles
               p.rank += 1 
               # wrap in a closure to ensure not only the last one is saved
               do (profile = p) -> update.push((done) -> profile.save(done))

            update.push((done) -> profile.save(done))
            
            async.parallel(update, cb)

module.exports = RankUpdateJob
