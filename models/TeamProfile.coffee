mongoose = require "mongoose"
Schema = mongoose.Schema
User = require "./User"
Team = require "./Team"
async = require "async"
MongoError = require "../errors/MongoError"
RestError = require "../errors/RestError"

teamProfileSchema = mongoose.Schema
   user_id: { type: Schema.Types.ObjectId, ref: "User", require: true, index: true }
   name: { type: String, require: true, index: true }
   team_id: { type: Schema.Types.ObjectId, ref: "Team", require: true, index: true }
   team_key: { type: String, require: true }
   team_name: { type: String, require: true }
   is_college: { type: Boolean, require: true }
   points:
      overall: { type: Number, require: true, default: 0 }
      knowledge: { type: Number, require: true, default: 0 }
      passion: { type: Number, require: true, default: 0 }
      dedication: { type: Number, require: true, default: 0 }
   friends: [{ type: Schema.Types.ObjectId, index: true, ref: "TeamProfile" }]
   events: [
      type: { type: String, require: true, }
      points_earned: 
         overall: { type: Number, require: true, default: 0 }
         knowledge: { type: Number, require: true, default: 0 }
         passion: { type: Number, require: true, default: 0 }
         dedication: { type: Number, require: true, default: 0 }
      meta: Schema.Types.Mixed
   ]
   team_image_url: { type: String, require: true }
   profile_image_url: { type: String, require: true }
   has_processing: { type: Boolean, require: true, index: true, default: false }
   waiting_events: [
      type: { type: String, require: true, }
      meta: Schema.Types.Mixed   
      is_processing: { type: Boolean, require: true, default: false }
   ]
   shouts: [
      _id: { type: Schema.Types.ObjectId, require: true }
      text: { type: String, require: true }
   ]

teamProfileSchema.statics.createAndAttach = (user, team_id, cb) ->
   context = @
   newId = new mongoose.Types.ObjectId

   # Check for existance
   context
   .find({user_id: user._id, team_id: team_id })
   .exec (err, data) ->
      return cb(new MongoError(err)) if err
      return cb(new RestError(409, "duplicate")) if data?.length != 0

      # Get team and current friends
      async.parallel 
         team: (done) -> Team.findById team_id, "full_name team_key", done
         user: (done) -> User.findById user._id, "profile_image_url first_name last_name", done
         friends: (done) ->
            # return without querying if user has no friends
            return done null, [] unless user.friends?.length > 0
            context
            .find({ team_id: team_id, user_id: { $in: user.friends }})
            .select("friends")
            .exec(done)
      , (err, results) ->
         return cb(new MongoError(err)) if err

         new_friends = []
         updated = 
            create: (done) ->
               context.create {
                  _id: newId
                  user_id: user._id 
                  name: "#{results.user.first_name} #{results.user.last_name}"
                  team_id: results.team._id
                  team_key: results.team.team_key
                  team_name: results.team.full_name
                  is_college: results.team.is_college
                  friends: new_friends
                  team_image_url: ""
                  profile_image_url: results.user.profile_image_url
               }, done
            update_owner: (done) ->
               User.update {_id: user._id}, {$addToSet: {team_profiles: newId}}, done

         # Swap team profile ids
         for p in results.friends
            p.friends.addToSet(newId)
            new_friends.push(p._id)
            updated[p._id] = (done) -> p.save(done)

         # Save all changes
         async.parallel updated, (err, result) ->
            return cb(new MongoError(err)) if err 
            cb null, result.create

module.exports = mongoose.model("TeamProfile", teamProfileSchema)