async = require "async"
Job = require "./Job"
Team = require "../models/Team"
TeamProfile = require "../models/TeamProfile"
Group = require "../models/Group"
_ = require "underscore"

class TeamRankUpdateJob extends Job
   constructor: (data = {}) ->
      data.is_locking = true
      data.type = "team_rank_update"

      if data.team_id
         data.meta = 
            team_id: data.team_id
            batch_size: data.batch_size 
         delete data.team_id
         delete data.batch_size
      else if not data.meta
         throw new Error("team_id is required to create TeamRankUpdateJob")

      data.meta.batch_size = data.batch_size or 40
      console.log 
      data.locking_id = "rank_#{data.meta.team_id}"
      super data

   run: (cb) =>
      Team.findById @meta.team_id, "points",  (err, team) =>      
         return cb(err) if err
         return cb(new Error("No team found for team_id: #{@meta.team_id}")) if err

         team.set("points", {overall: 0, passion: 0, dedication: 0, knowledge: 0})
         @rankBatch team, 0, (err) =>
            return cb(err) if err
            team.save (err) =>
               return cb(err) if err
               @rankGroups(team._id, cb)

   rankBatch: (team, skip, cb) =>
      TeamProfile
      .find({ team_id: team._id, is_active: true })
      .skip(skip)
      .limit(@meta.batch_size)
      .sort({"points.overall": -1, name: 1})
      .select("rank points is_active")
      .exec (err, profiles) =>
         return cb(err) if err
         return cb() if profiles.length < 1
         async.parallel
            batch: (done) =>
               if profiles.length == @meta.batch_size
                  @rankBatch team, skip + @meta.batch_size, done
               else
                  done()
            teamProfiles: (done) ->
               rank = skip + 1
               count = 0
               
               for profile in profiles
                  count++

                  # Add points to team
                  team.points.overall += profile.points.overall
                  team.points.passion += profile.points.passion
                  team.points.dedication += profile.points.dedication
                  team.points.knowledge += profile.points.knowledge
                  
                  profile.rank = rank++
                  profile.save (err) -> 
                     return done(err) if err
                     done() if --count == 0
         , cb

   rankGroups: (team_id, cb) ->
      TeamProfile
      .aggregate { $match: { team_id: team_id, is_active: true }}
      , { $unwind: "$groups" }
      , { $group: { 
         _id: "$groups.group_id",
         members: { $sum: 1 },
         overall: { $sum: "$points.overall" },
         passion: { $sum: "$points.passion" }, 
         dedication: { $sum: "$points.dedication" }, 
         knowledge: { $sum: "$points.knowledge" }}}
      , (err, groups) ->
         return cb(err) if err
         run = []

         for g in groups 
            do (group = g) ->
               run.push (done) ->
                  Group.update _id: group._id,
                     members: group.members
                     points: 
                        overall: group.overall
                        passion: group.passion
                        dedication: group.dedication
                        knowledge: group.knowledge
                  , done

         async.parallel run, cb

module.exports = TeamRankUpdateJob
