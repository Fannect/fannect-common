mongoose = require "mongoose"
InvalidArgumentError = require "../errors/InvalidArgumentError"
Schema = mongoose.Schema

highlightSchema = new mongoose.Schema
   owner_id: { type: Schema.Types.ObjectId, ref: "TeamProfile", require: true, index: true }
   owner_user_id: { type: Schema.Types.ObjectId, ref: "User", require: true, index: true }
   owner_name: { type: String, require: true }
   owner_verified: { type: String }
   owner_profile_image_url: { type: String }
   caption: { type: String, require: true }
   image_url: { type: String, require: true }
   comment_count: { type: Number, require: true, default: 0 }
   comments: [
      owner_id: { type: Schema.Types.ObjectId, ref: "TeamProfile", require: true, index: true }
      owner_user_id: { type: Schema.Types.ObjectId, ref: "User", require: true, index: true }
      owner_name: { type: String, require: true }
      owner_profile_image_url: { type: String }
      owner_verified: { type: String }
      team_id: { type: Schema.Types.ObjectId, ref: "Team", require: true }
      team_name: { type: String, require: true }   
      content: { type: String, require: true }
   ]
   up_voted_by: [{ type: Schema.Types.ObjectId, ref: "User" }]
   down_voted_by: [{ type: Schema.Types.ObjectId, ref: "User" }]
   up_votes: { type: Number, default: 0, require: true }
   down_votes: { type: Number, default: 0, require: true }
   team_id: { type: Schema.Types.ObjectId, ref: "Team", require: true, index: true }
   team_name: { type: String, require: true }
   league_key: { type: String, requre: true }
   league_name: { type: String, require: true }
   game_type: { type: String, require: true, index: true }
   game_meta: Schema.Types.Mixed
   favorite: { type: Boolean }

highlightSchema.statics.createAndAttach = (profile, options, cb) ->
   return cb new InvalidArgumentError("Required: image_url") unless options?.image_url
   highlight = new Highlight({
      team_id: profile.team_id
      team_name: profile.team_name
      owner_id: profile._id
      owner_user_id: profile.user_id
      owner_name: profile.name
      owner_verified: profile.verified
      owner_profile_image_url: profile.profile_image_url
   })

   # Extend with extra options
   highlight[k] = v for k, v of options
   
   highlight.save (err) ->
      return cb(new MongoError(err)) if err
      cb null, highlight
   
Highlight = module.exports = mongoose.model("Highlight", highlightSchema)



