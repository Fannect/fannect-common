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
   instagram: Schema.Types.Mixed
   friends: [{ type: Schema.Types.ObjectId, ref: "User", index: true }]
   team_profiles: [{ type: Schema.Types.ObjectId, ref: "TeamProfile" }]
   role: { type: String, default: "rookie" }
   invites: [{ type: Schema.Types.ObjectId, ref: "User" }]
   push:
      game_notice: { type: Boolean }
      points_notice: { type: Boolean }
   reload_stream: String
   verified: String
   birthday: Date
   gender: String

userSchema.methods.acceptInvite = (other_user_id, cb) ->
   # Require later to not have circular dependancy, may not even matter
   TeamProfile = require "./TeamProfile"
   user = @

   cb(next(new InvalidArgumentError("Required: other_user_id"))) unless other_user_id

   async.parallel
      other: (done) ->
         User.findById other_user_id, "friends", done
      me_profiles: (done) -> 
         TeamProfile.find {user_id:user._id}, "team_id friends friends_count", done
      other_profiles: (done) -> 
         TeamProfile.find {user_id:other_user_id}, "team_id friends friends_count", done
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
               do (mine = me, others = otherP) ->
                  mine.friends.addToSet(others._id)
                  others.friends.addToSet(mine._id)
                  updated.push (done) -> 
                     mine.friends_count = mine.friends.length
                     mine.save(done)
                  updated.push (done) -> 
                     others.friends_count = others.friends.length
                     others.save(done)
               break
         
      async.parallel updated, cb

userSchema.statics.sendInvite = (from, to_id, cb) ->
   # Require later to not have circular dependancy, may not even matter
   
   User.update { _id: to_id },
      $addToSet: { invites: from._id }
   , (err, result) ->
      return cb(new MongoError(err)) if err
      return cb(new RestError(400, "duplicate", "Duplicate: invite already sent")) unless result == 1
      cb()

      # send push
      unless process.env.NODE_TESTING and from?.first_name and from?.last_name
         parse.sendPushNotification 
            channels: ["user_#{to_id}"]
            data: 
               alert: "#{from.first_name} #{from.last_name} just sent you a Roster Request."
               event: "invite"
               title: "Roster Request"
         , (err) ->
            console.error "Failed to send invite push: ", err if err

User = module.exports = mongoose.model("User", userSchema)