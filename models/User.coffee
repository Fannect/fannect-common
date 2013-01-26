mongoose = require "mongoose"
Email = mongoose.SchemaTypes.Email
Url = mongoose.SchemaTypes.Url
Schema = mongoose.Schema
async = require "async"

userSchema = mongoose.Schema
   email: { type: Email, index: { unique: true }, lowercase: true, trim: true }
   password: { type: String, required: true }
   first_name: { type: String, required: true }
   last_name: { type: String, required: true }
   profile_image_url: { type: Url }
   refresh_token: { type: String, required: true }
   facebook_token: String
   twitter_token: String
   friends: [{ type: Schema.Types.ObjectId, ref: "User" }]
   team_profiles: [{ type: Schema.Types.ObjectId, ref: "TeamProfile" }]
   role: String
   invites: [{ type: Schema.Types.ObjectId, ref: "User" }]
   reload_stream: String

userSchema.methods.acceptInvite = (other_user_id, cb) ->
   # Require later to not have circular dependancy, may not even matter
   TeamProfile = require "./TeamProfile"
   user = @

   async.parallel
      other: (done) ->
         User.findById other_user_id, "friends", done
      me_profiles: (done) -> 
         TeamProfile.find {user_id:user._id}, "team_id friends", done
      other_profiles: (done) -> 
         TeamProfile.find {user_id:other_user_id}, "team_id friends", done
   , (err, results) ->
      other = results.other
      me_profiles = results.me_profiles
      other_profiles = results.other_profiles

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