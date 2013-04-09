mongoose = require "mongoose"
Schema = mongoose.Schema
async = require "async"
MongoError = require "../errors/MongoError"
RestError = require "../errors/RestError"
eventProcessor = require "../utils/eventProcessor"

eventSchema = new mongoose.Schema
   type: { type: String, require: true }
   event_key: { type: String }
   points_earned:
      passion: { type: Number, require: true }
      dedication: { type: Number, require: true }
      knowledge: { type: Number, require: true }
   meta: Schema.Types.Mixed

teamProfileSchema = new mongoose.Schema
   user_id: { type: Schema.Types.ObjectId, ref: "User", require: true, index: true }
   name: { type: String, require: true, index: true }
   team_id: { type: Schema.Types.ObjectId, ref: "Team", require: true, index: true }
   team_key: { type: String, require: true }
   team_name: { type: String, require: true }
   sport_name: { type: String, requie: true }
   sport_key: { type: String, requie: true }
   is_college: { type: Boolean, require: true }
   points:
      overall: { type: Number, require: true, default: 0 }
      knowledge: { type: Number, require: true, default: 0 }
      passion: { type: Number, require: true, default: 0 }
      dedication: { type: Number, require: true, default: 0 }
   rank: { type: Number, default: 0 }
   friends: [{ type: Schema.Types.ObjectId, index: true, ref: "TeamProfile" }]
   friends_count: { type: Number, default: 0 }
   events: [ eventSchema ]
   team_image_url: { type: String, require: true }
   profile_image_url: { type: String, require: true }
   waiting_events: [
      type: { type: String, require: true, }
      event_key: { type: String }
      meta: Schema.Types.Mixed
   ]
   shouts: [
      _id: { type: Schema.Types.ObjectId, require: true }
      text: { type: String, require: true }
   ]
   groups: [
      group_id: { type: Schema.Types.ObjectId, index: true, ref: "Group" }
      name: { type: String, require: true }
      tags: [{ type: String }]
   ]
   verified: String
   is_active: { type: Boolean, require: true, default: true }

teamProfileSchema.methods.processEvents = (team) ->
   return if not @waiting_events or @waiting_events.length < 1

   process = () =>
      ev = @waiting_events.pop()
      return unless ev?.type
      eventProcessor[ev.type](ev, team, @)
      process()

   process()

   # Reset points
   @points.passion = 0
   @points.dedication = 0
   @points.knowledge = 0
   @points.overall = 0

   for ev in @events
      @points.passion += ev.points_earned.passion if ev.points_earned.passion
      @points.dedication += ev.points_earned.dedication if ev.points_earned.dedication
      @points.knowledge += ev.points_earned.knowledge if ev.points_earned.knowledge

   @points.overall = @points.passion + @points.dedication + @points.knowledge

teamProfileSchema.statics.createAndAttach = (user, team_id, cb) ->
   context = @
   User = require "./User"
   Team = require "./Team"

   # Check for existance
   TeamProfile
   .findOne({user_id: user._id, team_id: team_id })
   .exec (err, newProfile) ->
      return cb(new MongoError(err)) if err
      return cb(new RestError(409, "duplicate")) if newProfile?.is_active
      # Get team and current friends
      async.parallel
         user: (done) -> User.findById user._id, "profile_image_url first_name last_name friends verified", done
         team: (done) -> Team.findById team_id, "full_name team_key is_college sport_name sport_key", done
         last: (done) -> context.findOne({team_id: team_id }).select("rank").sort("-rank").limit(1).exec(done)
      , (err, results) ->
         return cb(new MongoError(err)) if err
      
         context
         .find({ user_id: { $in: results.user.friends }, team_id: team_id})
         .select("friends friends_count")
         .exec (err, friends) ->
            return cb(new MongoError(err)) if err

            isNew = false
            unless newProfile
               isNew = true
               newProfile = new TeamProfile
                  _id: new mongoose.Types.ObjectId
                  user_id: user._id 
                  name: "#{results.user.first_name} #{results.user.last_name}"
                  sport_key: results.team.sport_key
                  sport_name: results.team.sport_name
                  team_id: results.team._id
                  team_key: results.team.team_key
                  team_name: results.team.full_name
                  is_college: results.team.is_college
                  team_image_url: ""
                  profile_image_url: results.user.profile_image_url
                  verified: results.user.verified
                  is_active: true
            else
               newProfile.is_active = true
            
            newProfile.rank = (results.last?.rank or 0) + 1

            new_friends = []
            updated = 
               newProfile: (done) -> newProfile.save(done)
               update_owner: (done) ->
                  User.update {_id: user._id}, {$addToSet: {team_profiles: newProfile._id}}, done

            # Swap team profile ids
            for p in friends
               do (profile = p) ->
                  profile.friends.addToSet(newProfile._id)
                  profile.friends_count++
                  new_friends.push(profile._id)
                  updated[profile._id] = (done) -> profile.save(done)

            # Update new profile
            newProfile.friends = new_friends
            newProfile.friends_count = new_friends.length

            # Save all changes
            async.parallel updated, (err, result) ->
               return cb(new MongoError(err)) if err

               # update rank
               unless isNew
                  ProfileRankUpdateJob = require("../jobs/ProfileRankUpdateJob")
                  job = new ProfileRankUpdateJob({ team_profile_id: newProfile._id, team_id: team_id })
                  job.queue()

               cb null, newProfile

TeamProfile = module.exports = mongoose.model("TeamProfile", teamProfileSchema)