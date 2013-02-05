mongoose = require "mongoose"
Email = mongoose.SchemaTypes.Email
Url = mongoose.SchemaTypes.Url
Schema = mongoose.Schema
async = require "async"
MongoError = require "../errors/MongoError"

userSchema = new mongoose.Schema
   email: { type: Email, index: { unique: true }, lowercase: true, trim: true }
   password: { type: String, required: true }
   first_name: { type: String, required: true }
   last_name: { type: String, required: true }
   profile_image_url: { type: String, require: true }
   refresh_token: { type: String, required: true, index: { unique: true }}
   facebook: Schema.Types.Mixed
   twitter: Schema.Types.Mixed
   friends: [{ type: Schema.Types.ObjectId, ref: "User", index: true }]
   team_profiles: [{ type: Schema.Types.ObjectId, ref: "TeamProfile" }]
   role: { type: String, default: "rookie" }
   invites: [{ type: Schema.Types.ObjectId, ref: "User" }]
   reload_stream: String

userSchema.methods.acceptInvite = (other_user_id, cb) ->
   # Require later to not have circular dependancy, may not even matter
   TeamProfile = require "./TeamProfile"
   user = @

   cb(next(new InvalidArgumentError("Required: other_user_id"))) unless other_user_id

   async.parallel
      other: (done) ->
         User.findById other_user_id, "friends", done
      me_profiles: (done) -> 
         TeamProfile.find {user_id:user._id}, "team_id friends", done
      other_profiles: (done) -> 
         TeamProfile.find {user_id:other_user_id}, "team_id friends", done
   , (err, results) ->
      cb(new MongoError(err)) if err

      other = results.other
      me_profiles = results.me_profiles
      other_profiles = results.other_profiles

      user.invites.remove(other._id)
      user.friends.addToSet(other._id)
      other.friends.addToSet(user._id)

      updated = [
         (done) -> user.save(done)
         (done) -> other.save(done)
      ]

      for me in me_profiles
         for otherP in other_profiles
            if me.team_id.toString() == otherP.team_id.toString()
               me.friends.addToSet(otherP._id)
               otherP.friends.addToSet(me._id)
               updated.push (done) -> me.save(done)
               updated.push (done) -> otherP.save(done)
               break
         
      async.parallel updated, cb

User = module.exports = mongoose.model("User", userSchema)